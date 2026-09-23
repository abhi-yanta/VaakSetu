import 'dart:math' as math;
import 'dart:ui';
import '../models/form_field_model.dart';

class FormFieldEngine {
  /// Computes Levenshtein distance between two strings
  static int levenshteinDistance(String a, String b) {
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    List<int> v0 = List<int>.generate(b.length + 1, (i) => i);
    List<int> v1 = List<int>.filled(b.length + 1, 0);

    for (int i = 0; i < a.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < b.length; j++) {
        final cost = (a.codeUnitAt(i) == b.codeUnitAt(j)) ? 0 : 1;
        v1[j + 1] = math.min(v1[j] + 1, math.min(v0[j + 1] + 1, v0[j] + cost));
      }
      for (int j = 0; j < v0.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v1[b.length];
  }

  /// Calculates normalized string similarity (0.0 to 1.0)
  static double stringSimilarity(String s1, String s2) {
    final a = s1.trim().toLowerCase();
    final b = s2.trim().toLowerCase();
    if (a == b) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;
    final maxLen = math.max(a.length, b.length);
    if (maxLen == 0) return 1.0;
    final dist = levenshteinDistance(a, b);
    return 1.0 - (dist / maxLen);
  }

  /// Cleans raw text for matching
  static String _cleanText(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[:\-_.*|/\\#]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Matches a single line against the field dictionary
  static ({String fieldKey, String canonicalLabel, String translatedLabel, double confidence})?
      matchLine(String rawLine, String langCode) {
    final clean = _cleanText(rawLine);
    if (clean.length < 2) return null;

    String? bestKey;
    double highestScore = 0.0;

    for (final entry in FormFieldDictionary.definitions.entries) {
      final def = entry.value;
      for (final kw in def.keywords) {
        final cleanKw = _cleanText(kw);
        if (cleanKw.isEmpty) continue;

        double score = 0.0;

        if (clean == cleanKw) {
          score = 1.0;
        } else if (clean.contains(cleanKw) || cleanKw.contains(clean)) {
          score = math.min(cleanKw.length, clean.length) / math.max(cleanKw.length, clean.length);
          score = math.max(score, 0.88);
        } else {
          final sim = stringSimilarity(clean, cleanKw);
          if (sim >= 0.72) {
            score = sim * 0.9;
          }
        }

        if (score > highestScore && score >= 0.68) {
          highestScore = score;
          bestKey = def.key;
        }
      }
    }

    if (bestKey != null) {
      final def = FormFieldDictionary.definitions[bestKey]!;
      return (
        fieldKey: bestKey,
        canonicalLabel: def.defaultLabel,
        translatedLabel: def.labels[langCode] ?? def.labels['hi'] ?? def.defaultLabel,
        confidence: highestScore,
      );
    }
    return null;
  }

  /// Parses text into form fields and calculates heuristic blank regions
  static List<FormFieldItem> parseDocumentToFormFields({
    required String rawText,
    required String langCode,
    double docWidth = 400.0,
    double docHeight = 650.0,
  }) {
    final rawLines = rawText.split(RegExp(r'[\r\n]+'));
    final detected = <FormFieldItem>[];
    final seenKeys = <String>{};

    int lineIndex = 0;
    for (final rawLine in rawLines) {
      final trimmed = rawLine.trim();
      if (trimmed.isEmpty) continue;

      final match = matchLine(trimmed, langCode);
      if (match != null && !seenKeys.contains(match.fieldKey)) {
        seenKeys.add(match.fieldKey);

        // Approximate label coordinates based on line sequence or layout
        final double topY = 60.0 + (detected.length * 68.0);
        final bool isTwoCol = detected.length % 2 == 1 && docWidth > 360;
        
        // Multi-column or stacked layout coordinates
        final double leftX = isTwoCol ? docWidth * 0.52 : 24.0;
        final double currentY = isTwoCol ? topY - 68.0 : topY;
        final double labelW = math.min(180.0, docWidth * 0.44);
        const double labelH = 26.0;

        final labelRect = Rect.fromLTWH(leftX, currentY, labelW, labelH);

        // Blank region heuristic: Below vs Right
        BlankPosition pos;
        Rect? blankBox;
        FieldConfidence conf;

        if (match.fieldKey == 'signature' || match.fieldKey == 'address') {
          // Signature and address boxes are spacious and placed below
          pos = BlankPosition.below;
          final double boxW = math.min(docWidth - leftX - 24.0, 260.0);
          final double boxH = match.fieldKey == 'signature' ? 70.0 : 60.0;
          blankBox = Rect.fromLTWH(leftX, currentY + labelH + 6.0, boxW, boxH);
          conf = FieldConfidence.green;
        } else if (match.fieldKey == 'phone' || match.fieldKey == 'dob' || match.fieldKey == 'date') {
          // Typically immediately to the right or below
          if (leftX + labelW + 110.0 < docWidth) {
            pos = BlankPosition.right;
            blankBox = Rect.fromLTWH(leftX + labelW + 8.0, currentY - 2.0, 120.0, 30.0);
            conf = FieldConfidence.green;
          } else {
            pos = BlankPosition.below;
            blankBox = Rect.fromLTWH(leftX, currentY + labelH + 6.0, labelW + 40.0, 30.0);
            conf = FieldConfidence.green;
          }
        } else {
          // Default below placement
          pos = BlankPosition.below;
          blankBox = Rect.fromLTWH(leftX, currentY + labelH + 6.0, math.max(labelW + 30.0, 160.0), 32.0);
          conf = match.confidence > 0.85 ? FieldConfidence.green : FieldConfidence.yellow;
        }

        detected.add(FormFieldItem(
          id: 'field_${match.fieldKey}_$lineIndex',
          fieldKey: match.fieldKey,
          label: match.canonicalLabel,
          translatedLabel: match.translatedLabel,
          matchedText: trimmed,
          matchConfidence: match.confidence,
          boundingBox: labelRect,
          blankRegion: blankBox,
          confidence: conf,
          blankPosition: pos,
          readingOrder: detected.length + 1,
        ));
      }
      lineIndex++;
    }

    // Sort in natural reading order (top-to-bottom, left-to-right)
    return sortReadingOrder(detected);
  }

  /// Sorts fields in natural top-to-bottom, left-to-right order
  static List<FormFieldItem> sortReadingOrder(List<FormFieldItem> fields) {
    final list = List<FormFieldItem>.from(fields);
    const double rowTolerance = 30.0;

    list.sort((a, b) {
      final yDiff = (a.boundingBox.top - b.boundingBox.top).abs();
      if (yDiff <= rowTolerance) {
        return a.boundingBox.left.compareTo(b.boundingBox.left);
      }
      return a.boundingBox.top.compareTo(b.boundingBox.top);
    });

    for (int i = 0; i < list.length; i++) {
      list[i] = list[i].copyWith(readingOrder: i + 1);
    }

    return list;
  }
}
