import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  TextRecognizer? _devanagariRecognizer;
  TextRecognizer? _latinRecognizer;

  OcrService() {
    _initRecognizers();
  }

  void _initRecognizers() {
    try {
      _devanagariRecognizer = TextRecognizer(script: TextRecognitionScript.devanagiri);
      _latinRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    } catch (e) {
      debugPrint("ML Kit Recognizer initialization: $e");
    }
  }

  /// Extracts text from image using on-device ML Kit recognition
  Future<String> extractText(String imagePath, {bool preferDevanagari = true}) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final buffer = StringBuffer();

    try {
      final recognizer = preferDevanagari ? (_devanagariRecognizer ?? _latinRecognizer) : _latinRecognizer;
      if (recognizer != null) {
        final RecognizedText recognizedText = await recognizer.processImage(inputImage);
        buffer.write(recognizedText.text);
      }

      // If Devanagari output was very short or empty, also run Latin recognizer to capture English numbers/clauses
      if (buffer.length < 20 && _latinRecognizer != null) {
        final latinText = await _latinRecognizer!.processImage(inputImage);
        if (latinText.text.isNotEmpty) {
          if (buffer.isNotEmpty) buffer.writeln();
          buffer.write(latinText.text);
        }
      }
    } catch (e) {
      debugPrint("OCR extraction error: $e");
      rethrow;
    }

    return buffer.toString().trim();
  }

  void dispose() {
    _devanagariRecognizer?.close();
    _latinRecognizer?.close();
  }
}
