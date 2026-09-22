import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  TextRecognizer? _devanagariRecognizer;
  TextRecognizer? _latinRecognizer;
  TextRecognizer? _chineseRecognizer; // Also handles Bengali/other Indic scripts via Latin+Devanagari combo

  OcrService() {
    _initRecognizers();
  }

  void _initRecognizers() {
    try {
      _devanagariRecognizer = TextRecognizer(script: TextRecognitionScript.devanagiri);
      _latinRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      // Chinese recognizer handles additional CJK-adjacent Indic text patterns
      _chineseRecognizer = TextRecognizer(script: TextRecognitionScript.chinese);
    } catch (e) {
      debugPrint("ML Kit Recognizer initialization: $e");
    }
  }

  /// Extracts text from image using on-device ML Kit recognition.
  /// Runs Devanagari + Latin in parallel (and Chinese for stamp papers with
  /// complex scripts like Bengali), then merges all results to maximise yield
  /// from multi-script official documents such as Non-Judicial Stamp Papers.
  Future<String> extractText(String imagePath, {bool preferDevanagari = true}) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final results = <String>{};

    // 1. Run Devanagari (Hindi/Marathi) recognizer
    if (_devanagariRecognizer != null) {
      try {
        final r = await _devanagariRecognizer!.processImage(inputImage);
        if (r.text.trim().isNotEmpty) results.add(r.text.trim());
      } catch (e) {
        debugPrint("Devanagari OCR error: $e");
      }
    }

    // 2. Always run Latin recognizer (catches English text on all stamp papers)
    if (_latinRecognizer != null) {
      try {
        final r = await _latinRecognizer!.processImage(inputImage);
        if (r.text.trim().isNotEmpty) results.add(r.text.trim());
      } catch (e) {
        debugPrint("Latin OCR error: $e");
      }
    }

    // 3. Run Chinese recognizer as a fallback for complex Indic/Bengali scripts
    //    that neither Devanagari nor Latin handles well (e.g. West Bengal deeds)
    final combinedSoFar = results.join(' ');
    if (combinedSoFar.length < 80 && _chineseRecognizer != null) {
      try {
        final r = await _chineseRecognizer!.processImage(inputImage);
        if (r.text.trim().isNotEmpty) results.add(r.text.trim());
      } catch (e) {
        debugPrint("Chinese/Indic OCR fallback error: $e");
      }
    }

    // Merge all extracted text, deduplicate by keeping unique non-overlapping blocks
    return _mergeResults(results.toList());
  }

  /// Merges multiple OCR outputs, preferring the longest unique segments
  String _mergeResults(List<String> parts) {
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first;

    // Sort by length descending so the richest result goes first
    parts.sort((a, b) => b.length.compareTo(a.length));

    // Build merged output: add each part only if it's not a near-subset of existing output
    final buffer = StringBuffer(parts.first);
    for (int i = 1; i < parts.length; i++) {
      final existing = buffer.toString().toLowerCase();
      final candidate = parts[i];
      // Add candidate lines that aren't already covered by primary result
      final newLines = candidate.split('\n').where((line) {
        final trimmed = line.trim();
        return trimmed.length > 4 && !existing.contains(trimmed.toLowerCase());
      });
      for (final line in newLines) {
        buffer.writeln();
        buffer.write(line);
      }
    }

    return buffer.toString().trim();
  }

  void dispose() {
    _devanagariRecognizer?.close();
    _latinRecognizer?.close();
    _chineseRecognizer?.close();
  }
}

