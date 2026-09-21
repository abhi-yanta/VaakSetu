import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../domain/models/language.dart';
import '../../domain/models/localized_content.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  VoidCallback? onSpeechStarted;
  VoidCallback? onSpeechFinished;

  bool get isPlaying => _isPlaying;

  Future<void> init() async {
    try {
      await _flutterTts.setSpeechRate(0.48); // Deliberate and clear for rural users
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setStartHandler(() {
        _isPlaying = true;
        onSpeechStarted?.call();
      });

      _flutterTts.setCompletionHandler(() {
        _isPlaying = false;
        onSpeechFinished?.call();
      });

      _flutterTts.setCancelHandler(() {
        _isPlaying = false;
        onSpeechFinished?.call();
      });

      _flutterTts.setErrorHandler((msg) {
        debugPrint("TTS Error: $msg");
        _isPlaying = false;
        onSpeechFinished?.call();
      });
    } catch (e) {
      debugPrint("TTS initialization notice: $e");
    }
  }

  Future<void> speak(String text, String langCode) async {
    if (text.isEmpty) return;

    try {
      await stop();
      final language = Language.fromCode(langCode);
      await _flutterTts.setLanguage(language.ttsLocale);
      _isPlaying = true;
      onSpeechStarted?.call();
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint("TTS speak error: $e");
      _isPlaying = false;
      onSpeechFinished?.call();
    }
  }

  Future<void> speakPrompt(String promptKey, String langCode) async {
    final text = LocalizedContent.getPrompt(langCode, promptKey);
    if (text.isNotEmpty) {
      await speak(text, langCode);
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint("TTS stop error: $e");
    } finally {
      _isPlaying = false;
      onSpeechFinished?.call();
    }
  }

  void dispose() {
    _flutterTts.stop();
  }
}
