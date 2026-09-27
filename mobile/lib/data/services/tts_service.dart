import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;

import '../../domain/models/language.dart';
import '../../domain/models/localized_content.dart';

/// Cached online TTS audio for instant replay of common phrases.
class _CachedAudio {
  final Uint8List bytes;
  final String layer; // 'bhashini' | 'ai4bharat'
  _CachedAudio({required this.bytes, required this.layer});
}

/// TtsService — Fast-start TTS for VaakSetu.
///
/// HOT PATH (speak): device TTS immediately — never silent-wait on network.
///   → Target: audible speech within ~1–2 seconds.
///   → Captions armed only when device/audio actually starts.
///
/// ONLINE (opportunistic, background):
///   LAYER 1 — Bhashini / ULCA (MeitY / AI4Bharat)
///   LAYER 2 — HuggingFace ai4bharat/indic-parler-tts
///   Prefetched + cached for the *next* utterance of the same text.
///
/// LAYER 3 (always): Device TTS via flutter_tts
class TtsService extends ChangeNotifier {
  // ──────────────────────────────────────────────────────────────────
  // Bhashini / ULCA (LAYER 1)
  // ──────────────────────────────────────────────────────────────────

  /// From Bhashini Udyat profile — passed via --dart-define / run_with_env.ps1
  static const String _bhashiniUserId = String.fromEnvironment(
    'BHASHINI_USER_ID',
    defaultValue: '',
  );
  static const String _bhashiniUdyatKey = String.fromEnvironment(
    'BHASHINI_UDYAT_KEY',
    defaultValue: '',
  );
  static const String _bhashiniInferenceKey = String.fromEnvironment(
    'BHASHINI_INFERENCE_KEY',
    defaultValue: '',
  );

  static const String _bhashiniConfigUrl =
      'https://meity-auth.ulcacontrib.org/ulca/apis/v0/model/getModelsPipeline';

  /// MeitY pipeline first, then AI4Bharat fallback (official ULCA pipeline IDs).
  static const List<String> _bhashiniPipelineIds = [
    '64392f96daac500b55c543cd', // MeitY
    '643930aa521a4b1ba0f4c41d', // AI4Bharat
  ];

  // ──────────────────────────────────────────────────────────────────
  // HuggingFace AI4Bharat (LAYER 2)
  // ──────────────────────────────────────────────────────────────────

  static const String _hfToken = String.fromEnvironment(
    'HF_TOKEN',
    defaultValue: '',
  );

  static const String _hfApiUrl =
      'https://api-inference.huggingface.co/models/ai4bharat/indic-parler-tts';

  // ──────────────────────────────────────────────────────────────────
  // Device TTS + audio playback
  // ──────────────────────────────────────────────────────────────────
  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isPlaying = false;
  String _activeTtsLayer = 'device'; // 'bhashini' | 'ai4bharat' | 'device'
  String? _lastSpokenText;
  String? _lastSpokenLangCode;
  bool _wasSpeakingBeforePause = false;

  /// Shorts-style caption karaoke (footer).
  List<String> _captionTokens = const [];
  int _captionActiveIndex = -1;
  Timer? _captionTimer;
  StreamSubscription<Duration>? _audioPosSub;
  /// True only after real audio/TTS has started — captions must not run early.
  bool _captionArmed = false;
  Completer<void>? _deviceSpeakCompleter;

  /// Incremented on every [stop]/[speak] so in-flight Bhashini/HF work
  /// cannot play audio after navigation or a newer speak request.
  int _speakGeneration = 0;

  /// Generation that owns the current device/audio utterance. Completion and
  /// cancel handlers only clear UI state when this still matches
  /// [_speakGeneration] — otherwise a newer [speak] already owns captions.
  int _activeUtteranceGeneration = 0;

  /// Serializes stop/play on both engines so an older async [stop] cannot
  /// halt audio that a newer [speak] already started.
  Future<void> _engineQueue = Future.value();

  /// Cached Bhashini compute endpoint + TTS serviceIds per language.
  String? _bhashiniCallbackUrl;
  String? _bhashiniPipelineIdUsed;
  final Map<String, String> _bhashiniServiceIds = {};
  /// In-flight Bhashini config fetches — shared by [prepareForLanguage] / prefetch.
  final Map<String, Future<String?>> _bhashiniServiceIdFutures = {};

  /// Online audio cache (lang+text → bytes). Instant path for tour/scanner tips.
  static const int _maxAudioCacheEntries = 32;
  final LinkedHashMap<String, _CachedAudio> _audioCache = LinkedHashMap();
  final Set<String> _prefetchInFlight = {};

  /// Hard caps so halt/init never add multi-second silence before speech.
  static const Duration _haltTimeout = Duration(milliseconds: 250);
  static const Duration _initStepTimeout = Duration(milliseconds: 800);

  VoidCallback? onSpeechStarted;
  VoidCallback? onSpeechFinished;

  bool get isPlaying => _isPlaying;
  String get activeTtsLayer => _activeTtsLayer;
  bool get wasSpeakingBeforePause => _wasSpeakingBeforePause;
  bool get hasLastSpoken =>
      _lastSpokenText != null &&
      _lastSpokenText!.isNotEmpty &&
      _lastSpokenLangCode != null;

  /// Tokens currently shown in the speaking caption bar (empty when idle).
  List<String> get captionTokens => _captionTokens;
  /// Index of the highlighted word (-1 when idle).
  int get captionActiveIndex => _captionActiveIndex;
  bool get hasActiveCaption =>
      _isPlaying && _captionTokens.isNotEmpty && _captionActiveIndex >= 0;

  bool get _bhashiniConfigured =>
      _bhashiniUserId.isNotEmpty &&
      _bhashiniUdyatKey.isNotEmpty &&
      _bhashiniInferenceKey.isNotEmpty;

  // ──────────────────────────────────────────────────────────────────
  // Initialization (lazy — never block first frame / runApp)
  // ──────────────────────────────────────────────────────────────────

  Future<void>? _initFuture;

  /// Idempotent warm-up. Safe to call from post-frame or before first speak.
  Future<void> ensureInitialized() => _initFuture ??= _initInternal();

  /// Alias for [ensureInitialized] (call sites / tests).
  Future<void> init() => ensureInitialized();

  Future<void> _initInternal() async {
    await _initDeviceTts();
    await _audioPlayer.setReleaseMode(ReleaseMode.stop);

    if (_bhashiniConfigured) {
      debugPrint(
        '[TTS] Bhashini keys present (Layer 1). '
        'HF=${_hfToken.isNotEmpty} device=always',
      );
    } else if (_hfToken.isNotEmpty) {
      debugPrint(
        '[TTS] Bhashini keys missing → HuggingFace Layer 2 ready. '
        'Set BHASHINI_USER_ID / BHASHINI_UDYAT_KEY / BHASHINI_INFERENCE_KEY '
        'via .env + tool/run_with_env.ps1 for Layer 1.',
      );
    } else {
      debugPrint(
        '[TTS] Online TTS keys missing → device TTS (Layer 3). '
        'Add Bhashini and/or HF_TOKEN via .env + tool/run_with_env.ps1',
      );
    }
  }

  /// Prefetch Bhashini pipeline + common prompt audio for [langCode].
  /// Never speaks or stops audio — warms cache for the next speak.
  Future<void> prepareForLanguage(String langCode) async {
    try {
      await ensureInitialized().timeout(const Duration(seconds: 2));
    } catch (_) {}
    if (_bhashiniConfigured) {
      unawaited(
        _ensureBhashiniServiceId(langCode).timeout(
          const Duration(seconds: 8),
          onTimeout: () => null,
        ),
      );
    }
    // Warm cache for high-frequency prompts so replay / next screen is instant.
    for (final key in const ['welcome', 'scan_prompt', 'processing']) {
      final text = LocalizedContent.getPrompt(langCode, key);
      if (text.isNotEmpty) {
        unawaited(_prefetchOnlineAudio(text, langCode));
      }
    }
  }

  /// Kick device init + Bhashini pipeline configs for all supported langs.
  /// Fire-and-forget from the language screen so first tour speak is warm.
  void warmLanguagePipelines() {
    unawaited(ensureInitialized().then((_) async {
      if (!_bhashiniConfigured) return;
      for (final lang in Language.supportedLanguages) {
        unawaited(_ensureBhashiniServiceId(lang.code));
      }
    }));
  }

  Future<void> _initDeviceTts() async {
    try {
      // Short timeouts — never block first speak for minutes on native hangs.
      await _flutterTts
          .setSpeechRate(0.45)
          .timeout(_initStepTimeout, onTimeout: () {});
      await _flutterTts
          .setVolume(1.0)
          .timeout(_initStepTimeout, onTimeout: () {});
      await _flutterTts
          .setPitch(1.0)
          .timeout(_initStepTimeout, onTimeout: () {});
      try {
        await _flutterTts
            .awaitSpeakCompletion(true)
            .timeout(_initStepTimeout, onTimeout: () {});
      } catch (_) {}

      _flutterTts.setStartHandler(() {
        if (!_isCurrentGeneration(_activeUtteranceGeneration)) return;
        _isPlaying = true;
        // Arm only when device TTS actually starts — never during network wait.
        _armCaptionPlayback(estimateMsPerToken: _estimateMsPerToken());
        notifyListeners();
        onSpeechStarted?.call();
      });
      _flutterTts.setCompletionHandler(() {
        _finishDeviceSpeak();
        // Ignore stale completion after a newer speak/stop took ownership.
        if (!_isCurrentGeneration(_activeUtteranceGeneration)) return;
        _clearCaption();
        _isPlaying = false;
        notifyListeners();
        onSpeechFinished?.call();
      });
      _flutterTts.setCancelHandler(() {
        _finishDeviceSpeak();
        if (!_isCurrentGeneration(_activeUtteranceGeneration)) return;
        _clearCaption();
        _isPlaying = false;
        notifyListeners();
        onSpeechFinished?.call();
      });
      _flutterTts.setErrorHandler((msg) {
        debugPrint('[TTS Device] Error: $msg');
        _finishDeviceSpeak();
        if (!_isCurrentGeneration(_activeUtteranceGeneration)) return;
        _clearCaption();
        _isPlaying = false;
        notifyListeners();
        onSpeechFinished?.call();
      });
      // Karaoke sync when device TTS reports word progress.
      _flutterTts.setProgressHandler((text, start, end, word) {
        if (!_isPlaying || !_captionArmed || _captionTokens.isEmpty) return;
        // Progress is authoritative — drop timer fallback.
        _captionTimer?.cancel();
        _captionTimer = null;
        // Prefer character-range mapping for strict sync.
        if (start >= 0 && _lastSpokenText != null) {
          final idx = _tokenIndexForCharOffset(start);
          if (idx != _captionActiveIndex) {
            _captionActiveIndex = idx;
            notifyListeners();
          }
          return;
        }
        final w = word.trim();
        if (w.isEmpty) return;
        final lower = w.toLowerCase();
        var idx = (_captionActiveIndex < 0 ? 0 : _captionActiveIndex);
        for (var i = idx; i < _captionTokens.length; i++) {
          final tok = _captionTokens[i].toLowerCase();
          if (tok == lower || tok.contains(lower) || lower.contains(tok)) {
            idx = i;
            break;
          }
        }
        if (idx != _captionActiveIndex) {
          _captionActiveIndex = idx;
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint('[TTS] Device init: $e');
    }
  }

  void _finishDeviceSpeak() {
    final c = _deviceSpeakCompleter;
    if (c != null && !c.isCompleted) c.complete();
    _deviceSpeakCompleter = null;
  }

  int _tokenIndexForCharOffset(int charOffset) {
    if (_captionTokens.isEmpty) return 0;
    // Rebuild approximate offsets from joined tokens + spaces.
    var cursor = 0;
    for (var i = 0; i < _captionTokens.length; i++) {
      final end = cursor + _captionTokens[i].length;
      if (charOffset <= end) return i;
      cursor = end + 1; // space
    }
    return _captionTokens.length - 1;
  }

  // ──────────────────────────────────────────────────────────────────
  // Public API
  // ──────────────────────────────────────────────────────────────────

  bool _isCurrentGeneration(int generation) => generation == _speakGeneration;

  Future<T> _enqueueEngineOp<T>(Future<T> Function() op) {
    final result = _engineQueue.then((_) => op());
    _engineQueue = result.then((_) {}, onError: (_) {});
    return result;
  }

  /// Fire-and-forget native interrupt — must NOT wait on [_engineQueue].
  /// Unblocks a queued/in-flight device utterance so [stop]/[speak] can
  /// cut over without waiting for the previous script to finish.
  void _interruptEnginesNow() {
    _finishDeviceSpeak();
    try {
      unawaited(_audioPlayer.stop());
    } catch (_) {}
    try {
      unawaited(_flutterTts.stop());
    } catch (_) {}
  }

  /// Stops both audioplayers and flutter_tts (queued, generation-aware).
  /// Each stop is hard-capped so halt never adds multi-second silence.
  Future<void> _haltBothEngines(int generation) {
    return _enqueueEngineOp(() async {
      if (!_isCurrentGeneration(generation)) return;
      try {
        await _audioPlayer.stop().timeout(_haltTimeout, onTimeout: () {});
      } catch (_) {}
      if (!_isCurrentGeneration(generation)) return;
      try {
        await _flutterTts.stop().timeout(_haltTimeout, onTimeout: () {});
      } catch (_) {}
    });
  }

  Future<void> speak(String text, String langCode) async {
    if (text.isEmpty) return;

    // Init must not block speak for long (already warm after first frame).
    try {
      await ensureInitialized().timeout(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('[TTS] Init slow/failed ($e) — continuing device fast-path');
    }

    // Own generation: invalidates any prior in-flight speak/network/play.
    final generation = ++_speakGeneration;
    _wasSpeakingBeforePause = false;
    // Cut previous audio immediately (do not wait for engine queue).
    _interruptEnginesNow();

    _lastSpokenText = text;
    _lastSpokenLangCode = langCode;
    _isPlaying = true;
    // Prepare tokens now; do NOT arm/advance until real audio starts.
    _prepareCaption(text);
    notifyListeners();

    // Await halt so a late stop cannot kill the utterance we are about to start.
    try {
      await _haltBothEngines(generation).timeout(
        const Duration(milliseconds: 600),
        onTimeout: () {
          debugPrint('[TTS] Halt timeout — speaking anyway');
        },
      );
    } catch (_) {}
    if (!_isCurrentGeneration(generation)) return;

    final cacheKey = _audioCacheKey(langCode, text);

    // Instant path: previously prefetched online audio (tour tips, welcome, etc.)
    final cached = _takeCachedAudio(cacheKey);
    if (cached != null) {
      _activeTtsLayer = cached.layer;
      debugPrint(
        '[TTS] Cache hit (${cached.layer}) — online voice immediately',
      );
      // Refresh cache in background for a subsequent replay.
      unawaited(_prefetchOnlineAudio(text, langCode));
      final ok = await _playAudioBytes(cached.bytes, generation);
      if (ok || !_isCurrentGeneration(generation)) return;
      // Fall through to device if cached playback failed.
    }

    // HOT PATH: device TTS immediately — never silent-wait on Bhashini/HF.
    // Online quality voice is prefetched for the *next* speak of this text.
    _activeTtsLayer = 'device';
    debugPrint('[TTS] Fast-path: device TTS (online prefetch in background)');
    unawaited(_prefetchOnlineAudio(text, langCode));
    await _speakViaDeviceTts(text, langCode, generation);
  }

  Future<void> speakPrompt(String promptKey, String langCode) async {
    final text = LocalizedContent.getPrompt(langCode, promptKey);
    if (text.isNotEmpty) await speak(text, langCode);
  }

  /// Re-speaks the most recent prompt. [speak] already stops overlapping audio.
  Future<void> replayLast() async {
    if (!hasLastSpoken) return;
    await speak(_lastSpokenText!, _lastSpokenLangCode!);
  }

  Future<void> pauseForBackground() async {
    if (!_isPlaying) return;
    _wasSpeakingBeforePause = true;
    await ensureInitialized();
    final generation = ++_speakGeneration;
    _interruptEnginesNow();
    await _haltBothEngines(generation);
    if (!_isCurrentGeneration(generation)) return;
    _clearCaption();
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> resumeFromBackground() async {
    if (!_wasSpeakingBeforePause || !hasLastSpoken) {
      _wasSpeakingBeforePause = false;
      return;
    }
    _wasSpeakingBeforePause = false;
    // Fresh speak() owns a new generation — avoids a dead paused state.
    await speak(_lastSpokenText!, _lastSpokenLangCode!);
  }

  /// Clears BOTH device TTS and audioplayers, and cancels in-flight speak.
  Future<void> stop() async {
    _wasSpeakingBeforePause = false;
    final generation = ++_speakGeneration;
    // Cut audio immediately so page navigation never waits on the old script.
    _interruptEnginesNow();
    // If init never started, nothing to halt on the native engines.
    if (_initFuture != null) {
      await ensureInitialized();
      await _haltBothEngines(generation);
    }
    if (!_isCurrentGeneration(generation)) return;
    _clearCaption();
    _isPlaying = false;
    notifyListeners();
    onSpeechFinished?.call();
  }

  @override
  void dispose() {
    _speakGeneration++;
    _clearCaption();
    _audioPlayer.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  // ──────────────────────────────────────────────────────────────────
  // Online fetch + cache (background only — never blocks hot-path speak)
  // ──────────────────────────────────────────────────────────────────

  String _audioCacheKey(String langCode, String text) =>
      '$langCode|${text.hashCode}|${text.length}';

  _CachedAudio? _takeCachedAudio(String key) {
    final entry = _audioCache.remove(key);
    if (entry == null) return null;
    // Re-insert at end (LRU touch) so we keep popular phrases.
    _audioCache[key] = entry;
    return entry;
  }

  void _putCachedAudio(String key, _CachedAudio audio) {
    _audioCache.remove(key);
    _audioCache[key] = audio;
    while (_audioCache.length > _maxAudioCacheEntries) {
      _audioCache.remove(_audioCache.keys.first);
    }
  }

  /// Fetch Bhashini/HF audio in the background and cache for the next speak.
  /// Never plays audio — avoids caption desync from mid-utterance switches.
  Future<void> _prefetchOnlineAudio(String text, String langCode) async {
    if (!_bhashiniConfigured && _hfToken.isEmpty) return;
    final key = _audioCacheKey(langCode, text);
    if (_audioCache.containsKey(key) || _prefetchInFlight.contains(key)) {
      return;
    }
    _prefetchInFlight.add(key);
    try {
      Uint8List? bytes;
      var layer = 'bhashini';

      if (_bhashiniConfigured) {
        try {
          bytes = await _fetchBhashiniAudio(text, langCode)
              .timeout(const Duration(seconds: 12));
        } catch (e) {
          debugPrint('[TTS Prefetch] Bhashini: $e');
        }
      }

      if ((bytes == null || bytes.isEmpty) && _hfToken.isNotEmpty) {
        layer = 'ai4bharat';
        try {
          bytes = await _fetchHuggingFaceAudio(text, langCode)
              .timeout(const Duration(seconds: 12));
        } catch (e) {
          debugPrint('[TTS Prefetch] HF: $e');
        }
      }

      if (bytes != null && bytes.isNotEmpty) {
        _putCachedAudio(key, _CachedAudio(bytes: bytes, layer: layer));
        debugPrint(
          '[TTS Prefetch] Cached $layer (${bytes.length} bytes) key=$key',
        );
      }
    } finally {
      _prefetchInFlight.remove(key);
    }
  }

  // ──────────────────────────────────────────────────────────────────
  // Layer 1: Bhashini ULCA TTS (fetch only)
  // ──────────────────────────────────────────────────────────────────

  Future<Uint8List?> _fetchBhashiniAudio(String text, String langCode) async {
    try {
      // Cap config+compute so a hung pipeline cannot run forever in background.
      final serviceId = await _ensureBhashiniServiceId(langCode)
          .timeout(const Duration(seconds: 6), onTimeout: () => null);
      if (serviceId == null || _bhashiniCallbackUrl == null) {
        debugPrint(
          '[TTS Bhashini] Config failed — no serviceId/callbackUrl '
          '(lang=$langCode)',
        );
        return null;
      }

      final computeBody = {
        'pipelineTasks': [
          {
            'taskType': 'tts',
            'config': {
              'language': {'sourceLanguage': langCode},
              'serviceId': serviceId,
              'gender': 'female',
            },
          },
        ],
        'inputData': {
          'input': [
            {'source': text},
          ],
        },
      };

      final response = await http
          .post(
            Uri.parse(_bhashiniCallbackUrl!),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': _bhashiniInferenceKey,
            },
            body: jsonEncode(computeBody),
          )
          .timeout(const Duration(seconds: 6));

      if (response.statusCode != 200) {
        debugPrint(
          '[TTS Bhashini] Compute HTTP ${response.statusCode} — skip',
        );
        return null;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        debugPrint('[TTS Bhashini] Unexpected compute JSON — skip');
        return null;
      }

      final audioB64 = _extractTtsAudioBase64(decoded);
      if (audioB64 == null || audioB64.isEmpty) {
        debugPrint('[TTS Bhashini] No audioContent in response — skip');
        return null;
      }

      final bytes = Uint8List.fromList(base64Decode(audioB64));
      debugPrint(
        '[TTS Bhashini] Got ${bytes.length} audio bytes '
        '(pipeline=$_bhashiniPipelineIdUsed)',
      );
      return bytes;
    } catch (e) {
      debugPrint('[TTS Bhashini] Exception: $e');
      return null;
    }
  }

  Future<String?> _ensureBhashiniServiceId(String langCode) {
    final cached = _bhashiniServiceIds[langCode];
    if (cached != null && _bhashiniCallbackUrl != null) {
      return Future.value(cached);
    }

    return _bhashiniServiceIdFutures.putIfAbsent(langCode, () async {
      try {
        for (final pipelineId in _bhashiniPipelineIds) {
          final ok = await _fetchBhashiniConfig(pipelineId, langCode);
          if (ok) {
            _bhashiniPipelineIdUsed = pipelineId;
            return _bhashiniServiceIds[langCode];
          }
          debugPrint(
            '[TTS Bhashini] Config failed for pipeline $pipelineId '
            '(lang=$langCode) — trying next',
          );
        }
        return null;
      } finally {
        // Allow retry on failure; success stays in _bhashiniServiceIds.
        if (_bhashiniServiceIds[langCode] == null) {
          _bhashiniServiceIdFutures.remove(langCode);
        }
      }
    });
  }

  Future<bool> _fetchBhashiniConfig(String pipelineId, String langCode) async {
    try {
      final body = {
        'pipelineTasks': [
          {
            'taskType': 'tts',
            'config': {
              'language': {'sourceLanguage': langCode},
            },
          },
        ],
        'pipelineRequestConfig': {'pipelineId': pipelineId},
      };

      final response = await http
          .post(
            Uri.parse(_bhashiniConfigUrl),
            headers: {
              'Content-Type': 'application/json',
              'userID': _bhashiniUserId,
              'ulcaApiKey': _bhashiniUdyatKey,
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        debugPrint(
          '[TTS Bhashini] Config HTTP ${response.statusCode} '
          'pipeline=$pipelineId',
        );
        return false;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return false;

      final endpoint = decoded['pipelineInferenceAPIEndPoint'];
      if (endpoint is Map<String, dynamic>) {
        final callback = endpoint['callbackUrl'] ?? endpoint['callbackURL'];
        if (callback is String && callback.isNotEmpty) {
          _bhashiniCallbackUrl = callback;
        }
      }

      if (_bhashiniCallbackUrl == null || _bhashiniCallbackUrl!.isEmpty) {
        debugPrint('[TTS Bhashini] Config missing callbackUrl');
        return false;
      }

      final serviceId = _findTtsServiceId(decoded, langCode);
      if (serviceId == null) {
        debugPrint(
          '[TTS Bhashini] No TTS serviceId for lang=$langCode '
          'in pipeline=$pipelineId',
        );
        return false;
      }

      _bhashiniServiceIds[langCode] = serviceId;
      debugPrint(
        '[TTS Bhashini] Config OK pipeline=$pipelineId lang=$langCode',
      );
      return true;
    } catch (e) {
      debugPrint('[TTS Bhashini] Config exception: $e');
      return false;
    }
  }

  String? _findTtsServiceId(Map<String, dynamic> configJson, String langCode) {
    final configs = configJson['pipelineResponseConfig'];
    if (configs is! List) return null;

    for (final task in configs) {
      if (task is! Map<String, dynamic>) continue;
      if (task['taskType'] != 'tts') continue;
      final entries = task['config'];
      if (entries is! List) continue;

      String? fallbackId;
      for (final entry in entries) {
        if (entry is! Map<String, dynamic>) continue;
        final id = entry['serviceId'];
        if (id is! String || id.isEmpty) continue;
        fallbackId ??= id;
        final lang = entry['language'];
        if (lang is Map && lang['sourceLanguage'] == langCode) {
          return id;
        }
      }
      return fallbackId;
    }
    return null;
  }

  String? _extractTtsAudioBase64(Map<String, dynamic> computeJson) {
    final pipeline = computeJson['pipelineResponse'];
    if (pipeline is List) {
      for (final item in pipeline) {
        if (item is! Map<String, dynamic>) continue;
        if (item['taskType'] != null && item['taskType'] != 'tts') continue;
        final audio = item['audio'];
        if (audio is List && audio.isNotEmpty) {
          final first = audio.first;
          if (first is Map && first['audioContent'] is String) {
            return first['audioContent'] as String;
          }
        }
      }
    }

    // Some gateways return a single TTS object at top level.
    final audio = computeJson['audio'];
    if (audio is List && audio.isNotEmpty) {
      final first = audio.first;
      if (first is Map && first['audioContent'] is String) {
        return first['audioContent'] as String;
      }
    }
    return null;
  }

  // ──────────────────────────────────────────────────────────────────
  // Layer 2: HuggingFace AI4Bharat Indic Parler-TTS (fetch only)
  // ──────────────────────────────────────────────────────────────────

  Future<Uint8List?> _fetchHuggingFaceAudio(
    String text,
    String langCode,
  ) async {
    try {
      final voiceDescription = _getVoiceDescription(langCode);

      final response = await http
          .post(
            Uri.parse(_hfApiUrl),
            headers: {
              'Authorization': 'Bearer $_hfToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'inputs': text,
              'parameters': {
                'description': voiceDescription,
                'language': _toBcp47(langCode),
              },
            }),
          )
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200 &&
          response.headers['content-type']?.contains('audio') == true) {
        return response.bodyBytes;
      }

      // Cold-start: one short retry only (background prefetch — not hot path).
      if (response.statusCode == 503) {
        debugPrint('[TTS HF] Model loading, one quick retry...');
        await Future.delayed(const Duration(milliseconds: 800));
        final retry = await http
            .post(
              Uri.parse(_hfApiUrl),
              headers: {
                'Authorization': 'Bearer $_hfToken',
                'Content-Type': 'application/json',
              },
              body: jsonEncode({
                'inputs': text,
                'parameters': {'description': voiceDescription},
              }),
            )
            .timeout(const Duration(seconds: 6));
        if (retry.statusCode == 200 &&
            retry.headers['content-type']?.contains('audio') == true) {
          return retry.bodyBytes;
        }
      }

      debugPrint('[TTS HF] Response ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('[TTS HF] Exception: $e');
      return null;
    }
  }

  /// Play WAV/MP3 bytes from Bhashini or HuggingFace via audioplayers.
  Future<bool> _playAudioBytes(List<int> bytes, int generation) async {
    if (!_isCurrentGeneration(generation)) return false;
    try {
      debugPrint('[TTS Audio] Playing ${bytes.length} bytes');
      // Start playback inside the queue; wait for completion outside so
      // a concurrent stop() can still halt the engines.
      Future<void>? completion;
      await _enqueueEngineOp(() async {
        if (!_isCurrentGeneration(generation)) return;
        try {
          await _flutterTts.stop();
        } catch (_) {}
        if (!_isCurrentGeneration(generation)) return;

        _activeUtteranceGeneration = generation;
        completion = _audioPlayer.onPlayerComplete.first;
        await _audioPlayer.play(
          BytesSource(Uint8List.fromList(bytes)),
        );
        if (!_isCurrentGeneration(generation)) return;

        // Arm captions only after play() — never during network wait.
        _isPlaying = true;
        _armCaptionPlayback();
        notifyListeners();
        onSpeechStarted?.call();
        unawaited(_syncCaptionToAudio(generation));
      });

      if (completion == null || !_isCurrentGeneration(generation)) {
        return false;
      }

      await completion!.timeout(const Duration(seconds: 60));

      if (!_isCurrentGeneration(generation)) return false;

      _clearCaption();
      _isPlaying = false;
      notifyListeners();
      onSpeechFinished?.call();
      return true;
    } catch (e) {
      debugPrint('[TTS Audio] Playback error: $e');
      await _enqueueEngineOp(() async {
        if (!_isCurrentGeneration(generation)) return;
        try {
          await _audioPlayer.stop();
        } catch (_) {}
      });
      if (!_isCurrentGeneration(generation)) return false;
      _clearCaption();
      _isPlaying = false;
      notifyListeners();
      onSpeechFinished?.call();
      return false;
    }
  }

  // ──────────────────────────────────────────────────────────────────
  // Layer 3: Device TTS (flutter_tts)
  // ──────────────────────────────────────────────────────────────────

  Future<void> _speakViaDeviceTts(
    String text,
    String langCode,
    int generation,
  ) async {
    if (!_isCurrentGeneration(generation)) return;
    try {
      final completer = Completer<void>();
      _deviceSpeakCompleter = completer;
      _activeUtteranceGeneration = generation;

      // Start inside the queue; wait for completion OUTSIDE so a concurrent
      // stop()/speak() halt can run without waiting for this utterance.
      // (Mirrors [_playAudioBytes] — awaitSpeakCompletion must not hold queue.)
      await _enqueueEngineOp(() async {
        if (!_isCurrentGeneration(generation)) return;
        try {
          await _audioPlayer.stop().timeout(_haltTimeout, onTimeout: () {});
        } catch (_) {}
        if (!_isCurrentGeneration(generation)) return;

        final language = Language.fromCode(langCode);
        // setLanguage can hang while downloading a voice pack — never wait long.
        try {
          await _flutterTts
              .setLanguage(language.ttsLocale)
              .timeout(_initStepTimeout, onTimeout: () {
            debugPrint(
              '[TTS Device] setLanguage timeout — speaking with default locale',
            );
          });
        } catch (e) {
          debugPrint('[TTS Device] setLanguage: $e');
        }
        if (!_isCurrentGeneration(generation)) return;

        _isPlaying = true;
        notifyListeners();

        // Kick off speak; do not await completion inside the engine queue.
        try {
          final speakFuture = _flutterTts.speak(text);
          unawaited(
            speakFuture.then((_) {}, onError: (_) {}),
          );
        } catch (e) {
          debugPrint('[TTS Device] speak kickoff error: $e');
          _finishDeviceSpeak();
        }
      });

      if (!_isCurrentGeneration(generation)) {
        _finishDeviceSpeak();
        return;
      }

      // Wait for cancel/completion handlers (or speak future) outside the queue.
      final pending = _deviceSpeakCompleter;
      if (pending != null && !pending.isCompleted) {
        await pending.future.timeout(
          Duration(milliseconds: _estimateSpeakTimeoutMs()),
          onTimeout: () {
            debugPrint('[TTS Device] Completion timeout — clearing');
          },
        );
      }

      if (!_isCurrentGeneration(generation)) return;

      // Handlers normally clear; ensure we don't leave a stuck playing state.
      if (_isPlaying) {
        _finishDeviceSpeak();
        _clearCaption();
        _isPlaying = false;
        notifyListeners();
        onSpeechFinished?.call();
      }
    } catch (e) {
      debugPrint('[TTS Device] speak error: $e');
      _finishDeviceSpeak();
      if (!_isCurrentGeneration(generation)) return;
      _clearCaption();
      _isPlaying = false;
      notifyListeners();
      onSpeechFinished?.call();
    }
  }

  // ──────────────────────────────────────────────────────────────────
  // Caption karaoke (YouTube Shorts–style footer)
  // ──────────────────────────────────────────────────────────────────

  /// Tokenize caption text. Does NOT start the ticker — call [_armCaptionPlayback]
  /// only when audio / device TTS has actually started.
  void _prepareCaption(String text) {
    _captionTimer?.cancel();
    _captionTimer = null;
    unawaited(_audioPosSub?.cancel());
    _audioPosSub = null;
    _captionArmed = false;

    _captionTokens = text
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .split(' ')
        .where((t) => t.isNotEmpty)
        .toList();
    // Stay at -1 until playback starts so the footer stays idle.
    _captionActiveIndex = -1;
  }

  /// Start karaoke highlighting. Resets index to 0. Optional timer is a
  /// fallback when device progress / audio position is unavailable.
  void _armCaptionPlayback({int? estimateMsPerToken}) {
    _captionTimer?.cancel();
    _captionTimer = null;

    _captionArmed = true;
    _captionActiveIndex = _captionTokens.isEmpty ? -1 : 0;

    if (estimateMsPerToken != null &&
        estimateMsPerToken > 0 &&
        _captionTokens.length > 1) {
      _captionTimer = Timer.periodic(
        Duration(milliseconds: estimateMsPerToken),
        (timer) {
          if (!_isPlaying || !_captionArmed || _captionTokens.isEmpty) {
            timer.cancel();
            return;
          }
          if (_captionActiveIndex < _captionTokens.length - 1) {
            _captionActiveIndex++;
            notifyListeners();
          } else {
            timer.cancel();
          }
        },
      );
    }
    notifyListeners();
  }

  int _estimateMsPerToken() {
    if (_captionTokens.isEmpty) return 340;
    final chars = (_lastSpokenText ?? '').length;
    // Slow, clear speech (~11–12 chars/sec) for rural listeners.
    final totalMs = (chars / 11.5 * 1000).clamp(900.0, 90000.0);
    return (totalMs / _captionTokens.length).round().clamp(160, 900);
  }

  int _estimateSpeakTimeoutMs() {
    final chars = (_lastSpokenText ?? '').length;
    return (10000 + chars * 90).clamp(12000, 180000);
  }

  Future<void> _syncCaptionToAudio(int generation) async {
    try {
      Duration? duration;
      for (var i = 0; i < 25; i++) {
        if (!_isCurrentGeneration(generation) || !_captionArmed) return;
        try {
          duration = await _audioPlayer.getDuration();
        } catch (_) {
          duration = null;
        }
        if (duration != null && duration.inMilliseconds > 200) break;
        await Future<void>.delayed(const Duration(milliseconds: 40));
      }
      if (!_isCurrentGeneration(generation) || !_captionArmed) return;
      if (duration == null ||
          duration.inMilliseconds < 200 ||
          _captionTokens.isEmpty) {
        // Duration unknown — fall back to estimated timer.
        if (_captionTokens.length > 1 && _captionTimer == null) {
          _armCaptionPlayback(estimateMsPerToken: _estimateMsPerToken());
        }
        return;
      }

      final totalMs = duration.inMilliseconds;

      // Switch from any timer fallback to audio-position-driven index.
      _captionTimer?.cancel();
      _captionTimer = null;
      await _audioPosSub?.cancel();
      _audioPosSub = _audioPlayer.onPositionChanged.listen((pos) {
        if (!_isCurrentGeneration(generation) ||
            !_isPlaying ||
            !_captionArmed) {
          return;
        }
        if (totalMs <= 0 || _captionTokens.isEmpty) return;
        final idx = ((pos.inMilliseconds / totalMs) * _captionTokens.length)
            .floor()
            .clamp(0, _captionTokens.length - 1);
        if (idx != _captionActiveIndex) {
          _captionActiveIndex = idx;
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint('[TTS Caption] audio sync: $e');
    }
  }

  void _clearCaption() {
    _captionTimer?.cancel();
    _captionTimer = null;
    unawaited(_audioPosSub?.cancel());
    _audioPosSub = null;
    _captionArmed = false;
    _captionTokens = const [];
    _captionActiveIndex = -1;
  }

  // ──────────────────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────────────────

  String _getVoiceDescription(String langCode) {
    const Map<String, String> descriptions = {
      'hi':
          'A clear female Hindi voice speaking slowly and distinctly, '
              'suitable for rural listeners. Calm, authoritative tone.',
      'ta':
          'A clear female Tamil voice speaking slowly and distinctly, '
              'suitable for rural listeners. Calm, authoritative tone.',
      'te':
          'A clear female Telugu voice speaking slowly and distinctly. '
              'Calm, authoritative tone.',
      'mr':
          'A clear female Marathi voice speaking slowly. '
              'Calm, authoritative tone.',
      'bn':
          'A clear female Bengali voice speaking slowly and distinctly. '
              'Calm, authoritative tone.',
      'gu':
          'A clear female Gujarati voice speaking slowly. '
              'Calm, authoritative tone.',
      'kn':
          'A clear female Kannada voice speaking slowly. '
              'Calm, authoritative tone.',
      'ml':
          'A clear female Malayalam voice speaking slowly. '
              'Calm, authoritative tone.',
    };
    return descriptions[langCode] ??
        'A clear female Indian voice speaking slowly and distinctly, '
            'suitable for rural listeners. Calm tone.';
  }

  String _toBcp47(String code) {
    const map = {
      'hi': 'hi-IN',
      'ta': 'ta-IN',
      'te': 'te-IN',
      'mr': 'mr-IN',
      'bn': 'bn-IN',
      'gu': 'gu-IN',
      'kn': 'kn-IN',
      'ml': 'ml-IN',
      'or': 'or-IN',
      'pa': 'pa-IN',
      'as': 'as-IN',
      'ur': 'ur-IN',
    };
    return map[code] ?? 'hi-IN';
  }
}
