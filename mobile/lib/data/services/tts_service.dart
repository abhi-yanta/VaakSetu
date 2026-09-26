import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;

import '../../domain/models/language.dart';
import '../../domain/models/localized_content.dart';

/// TtsService — Smart 3-layer TTS engine for VaakSetu.
///
/// LAYER 1 (Best — Bhashini / ULCA online):
///   → Pipeline Config + Compute (MeitY / AI4Bharat)
///   → Requires BHASHINI_USER_ID + BHASHINI_UDYAT_KEY + BHASHINI_INFERENCE_KEY
///
/// LAYER 2 (Good — HuggingFace AI4Bharat):
///   → HuggingFace Inference API for ai4bharat/indic-parler-tts
///   → Requires HF_TOKEN
///
/// LAYER 3 (Always available — offline):
///   → Device TTS via flutter_tts
///
/// Priority: Bhashini → HuggingFace → Device TTS
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

  /// Incremented on every [stop]/[speak] so in-flight Bhashini/HF work
  /// cannot play audio after navigation or a newer speak request.
  int _speakGeneration = 0;

  /// Serializes stop/play on both engines so an older async [stop] cannot
  /// halt audio that a newer [speak] already started.
  Future<void> _engineQueue = Future.value();

  /// Cached Bhashini compute endpoint + TTS serviceIds per language.
  String? _bhashiniCallbackUrl;
  String? _bhashiniPipelineIdUsed;
  final Map<String, String> _bhashiniServiceIds = {};

  VoidCallback? onSpeechStarted;
  VoidCallback? onSpeechFinished;

  bool get isPlaying => _isPlaying;
  String get activeTtsLayer => _activeTtsLayer;
  bool get wasSpeakingBeforePause => _wasSpeakingBeforePause;
  bool get hasLastSpoken =>
      _lastSpokenText != null &&
      _lastSpokenText!.isNotEmpty &&
      _lastSpokenLangCode != null;

  bool get _bhashiniConfigured =>
      _bhashiniUserId.isNotEmpty &&
      _bhashiniUdyatKey.isNotEmpty &&
      _bhashiniInferenceKey.isNotEmpty;

  // ──────────────────────────────────────────────────────────────────
  // Initialization
  // ──────────────────────────────────────────────────────────────────
  Future<void> init() async {
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

  Future<void> _initDeviceTts() async {
    try {
      await _flutterTts.setSpeechRate(0.45);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setStartHandler(() {
        _isPlaying = true;
        notifyListeners();
        onSpeechStarted?.call();
      });
      _flutterTts.setCompletionHandler(() {
        _isPlaying = false;
        notifyListeners();
        onSpeechFinished?.call();
      });
      _flutterTts.setCancelHandler(() {
        _isPlaying = false;
        notifyListeners();
        onSpeechFinished?.call();
      });
      _flutterTts.setErrorHandler((msg) {
        debugPrint('[TTS Device] Error: $msg');
        _isPlaying = false;
        notifyListeners();
        onSpeechFinished?.call();
      });
    } catch (e) {
      debugPrint('[TTS] Device init: $e');
    }
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

  /// Stops both audioplayers and flutter_tts (queued, generation-aware).
  Future<void> _haltBothEngines(int generation) {
    return _enqueueEngineOp(() async {
      if (!_isCurrentGeneration(generation)) return;
      try {
        await _audioPlayer.stop();
      } catch (_) {}
      if (!_isCurrentGeneration(generation)) return;
      try {
        await _flutterTts.stop();
      } catch (_) {}
    });
  }

  Future<void> speak(String text, String langCode) async {
    if (text.isEmpty) return;

    // Own generation: invalidates any prior in-flight speak/network/play.
    final generation = ++_speakGeneration;
    _wasSpeakingBeforePause = false;
    await _haltBothEngines(generation);
    if (!_isCurrentGeneration(generation)) return;

    _lastSpokenText = text;
    _lastSpokenLangCode = langCode;
    _isPlaying = true;
    notifyListeners();
    onSpeechStarted?.call();

    // Layer 1: Bhashini
    if (_bhashiniConfigured) {
      final ok = await _speakViaBhashini(text, langCode, generation);
      if (!_isCurrentGeneration(generation)) return;
      if (ok) {
        _activeTtsLayer = 'bhashini';
        debugPrint('[TTS] Layer used: bhashini');
        return;
      }
      debugPrint('[TTS] Bhashini failed → falling back to next layer');
    } else {
      debugPrint(
        '[TTS] Skipping Bhashini (keys not set) → next layer',
      );
    }

    if (!_isCurrentGeneration(generation)) return;

    // Layer 2: HuggingFace
    if (_hfToken.isNotEmpty) {
      final ok = await _speakViaHuggingFace(text, langCode, generation);
      if (!_isCurrentGeneration(generation)) return;
      if (ok) {
        _activeTtsLayer = 'ai4bharat';
        debugPrint('[TTS] Layer used: ai4bharat (HuggingFace)');
        return;
      }
      debugPrint('[TTS] HuggingFace failed → falling back to device TTS');
    } else {
      debugPrint('[TTS] Skipping HuggingFace (HF_TOKEN not set) → device TTS');
    }

    if (!_isCurrentGeneration(generation)) return;

    // Layer 3: Device TTS
    _activeTtsLayer = 'device';
    debugPrint('[TTS] Layer used: device');
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
    final generation = ++_speakGeneration;
    await _haltBothEngines(generation);
    if (!_isCurrentGeneration(generation)) return;
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> resumeFromBackground() async {
    if (_wasSpeakingBeforePause &&
        _lastSpokenText != null &&
        _lastSpokenLangCode != null) {
      _wasSpeakingBeforePause = false;
      await speak(_lastSpokenText!, _lastSpokenLangCode!);
    }
  }

  /// Clears BOTH device TTS and audioplayers, and cancels in-flight speak.
  Future<void> stop() async {
    _wasSpeakingBeforePause = false;
    final generation = ++_speakGeneration;
    await _haltBothEngines(generation);
    if (!_isCurrentGeneration(generation)) return;
    _isPlaying = false;
    notifyListeners();
    onSpeechFinished?.call();
  }

  @override
  void dispose() {
    _speakGeneration++;
    _audioPlayer.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  // ──────────────────────────────────────────────────────────────────
  // Layer 1: Bhashini ULCA TTS
  // ──────────────────────────────────────────────────────────────────

  Future<bool> _speakViaBhashini(
    String text,
    String langCode,
    int generation,
  ) async {
    try {
      final serviceId = await _ensureBhashiniServiceId(langCode);
      if (!_isCurrentGeneration(generation)) return false;
      if (serviceId == null || _bhashiniCallbackUrl == null) {
        debugPrint(
          '[TTS Bhashini] Config failed — no serviceId/callbackUrl '
          '(lang=$langCode)',
        );
        return false;
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
          .timeout(const Duration(seconds: 20));

      if (!_isCurrentGeneration(generation)) return false;

      if (response.statusCode != 200) {
        debugPrint(
          '[TTS Bhashini] Compute HTTP ${response.statusCode} — fallback',
        );
        return false;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        debugPrint('[TTS Bhashini] Unexpected compute JSON — fallback');
        return false;
      }

      final audioB64 = _extractTtsAudioBase64(decoded);
      if (audioB64 == null || audioB64.isEmpty) {
        debugPrint('[TTS Bhashini] No audioContent in response — fallback');
        return false;
      }

      final bytes = base64Decode(audioB64);
      debugPrint(
        '[TTS Bhashini] Got ${bytes.length} audio bytes '
        '(pipeline=$_bhashiniPipelineIdUsed)',
      );
      return await _playAudioBytes(bytes, generation);
    } catch (e) {
      debugPrint('[TTS Bhashini] Exception: $e');
      return false;
    }
  }

  Future<String?> _ensureBhashiniServiceId(String langCode) async {
    final cached = _bhashiniServiceIds[langCode];
    if (cached != null && _bhashiniCallbackUrl != null) return cached;

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
          .timeout(const Duration(seconds: 15));

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
  // Layer 2: HuggingFace AI4Bharat Indic Parler-TTS
  // ──────────────────────────────────────────────────────────────────

  Future<bool> _speakViaHuggingFace(
    String text,
    String langCode,
    int generation,
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
          .timeout(const Duration(seconds: 10));

      if (!_isCurrentGeneration(generation)) return false;

      if (response.statusCode == 200 &&
          response.headers['content-type']?.contains('audio') == true) {
        return await _playAudioBytes(response.bodyBytes, generation);
      }

      if (response.statusCode == 503) {
        debugPrint('[TTS HF] Model loading, retrying in 3s...');
        await Future.delayed(const Duration(seconds: 3));
        if (!_isCurrentGeneration(generation)) return false;
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
            .timeout(const Duration(seconds: 12));
        if (!_isCurrentGeneration(generation)) return false;
        if (retry.statusCode == 200 &&
            retry.headers['content-type']?.contains('audio') == true) {
          return await _playAudioBytes(retry.bodyBytes, generation);
        }
      }

      debugPrint('[TTS HF] Response ${response.statusCode}');
      return false;
    } catch (e) {
      debugPrint('[TTS HF] Exception: $e');
      return false;
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

        _isPlaying = true;
        notifyListeners();

        completion = _audioPlayer.onPlayerComplete.first;
        await _audioPlayer.play(
          BytesSource(Uint8List.fromList(bytes)),
        );
      });

      if (completion == null || !_isCurrentGeneration(generation)) {
        return false;
      }

      await completion!.timeout(const Duration(seconds: 60));

      if (!_isCurrentGeneration(generation)) return false;

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
      await _enqueueEngineOp(() async {
        if (!_isCurrentGeneration(generation)) return;
        try {
          await _audioPlayer.stop();
        } catch (_) {}
        if (!_isCurrentGeneration(generation)) return;

        final language = Language.fromCode(langCode);
        await _flutterTts.setLanguage(language.ttsLocale);
        if (!_isCurrentGeneration(generation)) return;
        await _flutterTts.speak(text);
      });
    } catch (e) {
      debugPrint('[TTS Device] speak error: $e');
      if (!_isCurrentGeneration(generation)) return;
      _isPlaying = false;
      notifyListeners();
      onSpeechFinished?.call();
    }
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
