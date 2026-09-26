import 'dart:math' as math;
import 'dart:ui';
import '../models/form_field_model.dart';

class FormFieldEngine {
  /// Strong form-title / section hints (mirrors RuleEngine category markers).
  static const List<String> formHints = [
    'registration form',
    'application form',
    'application for',
    'beneficiary form',
    'kyc form',
    'kyc',
    'scholarship',
    'ration card',
    'job application',
    'employment application',
    'personal details',
    'applicant details',
    'declaration',
    'fill in capital',
    'please fill',
    'आवेदन पत्र',
    'आवेदन फॉर्म',
    'पंजीकरण फॉर्म',
    'पंजीकरण पत्र',
    'फॉर्म',
    'घोषणा',
    'व्यक्तिगत विवरण',
    'விண்ணப்ப படிவம்',
    'పదవీ దరఖాస్తు',
    'దరఖాస్తు ఫారం',
  ];

  static const List<String> sectionHeaders = [
    'personal details',
    'family details',
    'contact details',
    'bank details',
    'address details',
    'educational details',
    'declaration',
    'for office use',
    'व्यक्तिगत विवरण',
    'पारिवारिक विवरण',
    'बैंक विवरण',
    'घोषणा',
  ];

  /// Fields that typically use a wide blank box below the label.
  static const Set<String> _belowPreferKeys = {
    'signature',
    'address',
    'bank_account',
    'occupation',
    'education',
  };

  /// Compact fields that often sit to the right of the label.
  static const Set<String> _rightPreferKeys = {
    'phone',
    'dob',
    'date',
    'age',
    'pincode',
    'email',
    'gender',
    'ifsc',
    'category',
    'marital_status',
  };

  /// Returns true when the document looks like a fillable registration form.
  static bool looksLikeForm(String rawText) {
    final trimmed = rawText.trim();
    if (trimmed.isEmpty) return false;

    final lower = trimmed.toLowerCase();
    int hintScore = 0;

    for (final hint in formHints) {
      if (lower.contains(hint)) {
        hintScore += 2;
        break;
      }
    }
    for (final section in sectionHeaders) {
      if (lower.contains(section)) {
        hintScore += 1;
        break;
      }
    }

    final lines = trimmed
        .split(RegExp(r'[\r\n]+'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final colonLines = lines.where((l) => l.contains(':')).length;
    if (colonLines >= 3) hintScore += 1;

    final numberedLines =
        lines.where((l) => RegExp(r'^\d+[\.\)\:\-]').hasMatch(l)).length;
    if (numberedLines >= 3) hintScore += 1;

    final fields =
        parseDocumentToFormFields(rawText: trimmed, langCode: 'hi');
    if (fields.length >= 2) return true;
    if (fields.isNotEmpty && hintScore >= 2) return true;
    if (hintScore >= 3) return true;
    return false;
  }

  /// Levenshtein edit distance between two strings.
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

  /// Jaccard token overlap for multi-word labels (OCR-tolerant).
  static double tokenOverlap(String s1, String s2) {
    final a = _tokenize(_cleanText(s1));
    final b = _tokenize(_cleanText(s2));
    if (a.isEmpty || b.isEmpty) return 0.0;
    final intersection = a.intersection(b).length;
    final union = a.union(b).length;
    if (union == 0) return 0.0;
    return intersection / union;
  }

  /// True when every keyword token appears in the line (order-independent).
  static double tokenCoverage(String line, String keyword) {
    final lineTokens = _tokenize(_cleanText(line));
    final kwTokens = _tokenize(_cleanText(keyword));
    if (kwTokens.isEmpty) return 0.0;
    if (kwTokens.every(lineTokens.contains)) {
      return kwTokens.length / math.max(lineTokens.length, kwTokens.length);
    }
    return 0.0;
  }

  static Set<String> _tokenize(String text) {
    return text
        .split(RegExp(r'\s+'))
        .where((t) => t.length >= 2)
        .toSet();
  }

  /// Cleans raw text for matching
  static String _cleanText(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[:\-_.*|/\\#\(\)\[\]]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Strips leading enumerated markers: "1. Full Name" → "Full Name"
  static String stripLineNumber(String line) {
    return line
        .trim()
        .replaceFirst(RegExp(r'^\s*\d{1,2}[\.\)\:\-]\s*'), '')
        .trim();
  }

  /// Isolates the label side of "Label: filled value" lines.
  static String labelPortion(String line) {
    final stripped = stripLineNumber(line);
    final colonIdx = stripped.indexOf(':');
    if (colonIdx > 0) {
      return stripped.substring(0, colonIdx).trim();
    }
    return stripped;
  }

  /// Skip pure section headers that are not fillable fields.
  static bool isSectionHeader(String line) {
    final clean = _cleanText(labelPortion(line));
    if (clean.isEmpty) return true;
    for (final header in sectionHeaders) {
      if (clean == _cleanText(header) ||
          (clean.contains(_cleanText(header)) && clean.length < 40)) {
        return true;
      }
    }
    return false;
  }

  static double _scoreAgainstKeyword(String candidate, String keyword) {
    final clean = _cleanText(candidate);
    final cleanKw = _cleanText(keyword);
    if (clean.isEmpty || cleanKw.isEmpty) return 0.0;

    // Exact match
    if (clean == cleanKw) return 1.0;

    // Prefer longer keywords to avoid "name" stealing "father's name"
    final lengthBonus = math.min(0.08, cleanKw.length / 200.0);

    // Containment (bilingual lines often embed the keyword)
    if (clean.contains(cleanKw)) {
      final ratio = cleanKw.length / clean.length;
      return math.max(0.90, 0.82 + ratio * 0.15) + lengthBonus;
    }
    if (cleanKw.contains(clean) && clean.length >= 3) {
      final ratio = clean.length / cleanKw.length;
      if (ratio >= 0.55) {
        return math.max(0.78, ratio * 0.95) + lengthBonus;
      }
    }

    // Token coverage: all keyword tokens present in line
    final coverage = tokenCoverage(clean, cleanKw);
    if (coverage >= 0.45 && _tokenize(cleanKw).length >= 2) {
      return 0.86 + coverage * 0.1 + lengthBonus;
    }

    // Token overlap (Jaccard)
    final overlap = tokenOverlap(clean, cleanKw);
    if (overlap >= 0.5) {
      return 0.72 + overlap * 0.2 + lengthBonus;
    }

    // Fuzzy Levenshtein for OCR typos on short labels
    if (cleanKw.length <= 28 && clean.length <= 40) {
      final sim = stringSimilarity(clean, cleanKw);
      if (sim >= 0.78) {
        return sim * 0.92 + lengthBonus;
      }
      if (sim >= 0.70 && cleanKw.length <= 12) {
        return sim * 0.85;
      }
    }

    return 0.0;
  }

  /// Matches a single line against the field dictionary
  static ({String fieldKey, String canonicalLabel, String translatedLabel, double confidence})?
      matchLine(String rawLine, String langCode) {
    if (isSectionHeader(rawLine)) return null;

    final label = labelPortion(rawLine);
    final clean = _cleanText(label);
    if (clean.length < 2) return null;

    // Score bilingual halves separately: "Full Name / पूरा नाम"
    final candidates = <String>{label};
    for (final part in label.split(RegExp(r'\s*/\s*'))) {
      final p = part.trim();
      if (p.length >= 2) candidates.add(p);
    }

    String? bestKey;
    double highestScore = 0.0;

    for (final entry in FormFieldDictionary.definitions.entries) {
      final def = entry.value;
      for (final kw in def.keywords) {
        for (final candidate in candidates) {
          final score = _scoreAgainstKeyword(candidate, kw);
          // Longer keywords win ties (father_name over name)
          final adjusted = score + (kw.length * 0.0001);
          if (adjusted > highestScore && score >= 0.68) {
            highestScore = score;
            bestKey = def.key;
          }
        }
      }
    }

    if (bestKey != null) {
      final def = FormFieldDictionary.definitions[bestKey]!;
      return (
        fieldKey: bestKey,
        canonicalLabel: def.defaultLabel,
        translatedLabel:
            def.labels[langCode] ?? def.labels['hi'] ?? def.defaultLabel,
        confidence: highestScore.clamp(0.0, 1.0),
      );
    }
    return null;
  }

  /// Maps match score + blank certainty → green / yellow / red.
  static FieldConfidence confidenceFromScore(
    double matchScore, {
    required BlankPosition blankPosition,
  }) {
    if (blankPosition == BlankPosition.unclear || matchScore < 0.72) {
      return FieldConfidence.red;
    }
    if (matchScore >= 0.88) {
      return FieldConfidence.green;
    }
    if (matchScore >= 0.78) {
      return FieldConfidence.yellow;
    }
    return FieldConfidence.yellow;
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

        final double topY = 60.0 + (detected.length * 68.0);
        final bool isTwoCol = detected.length % 2 == 1 && docWidth > 360;

        final double leftX = isTwoCol ? docWidth * 0.52 : 24.0;
        final double currentY = isTwoCol ? topY - 68.0 : topY;
        final double labelW = math.min(180.0, docWidth * 0.44);
        const double labelH = 26.0;

        final labelRect = Rect.fromLTWH(leftX, currentY, labelW, labelH);

        BlankPosition pos;
        Rect? blankBox;

        if (_belowPreferKeys.contains(match.fieldKey)) {
          pos = BlankPosition.below;
          final double boxW = math.min(docWidth - leftX - 24.0, 260.0);
          final double boxH = match.fieldKey == 'signature'
              ? 70.0
              : (match.fieldKey == 'address' ? 60.0 : 36.0);
          blankBox = Rect.fromLTWH(leftX, currentY + labelH + 6.0, boxW, boxH);
        } else if (_rightPreferKeys.contains(match.fieldKey)) {
          if (leftX + labelW + 110.0 < docWidth) {
            pos = BlankPosition.right;
            blankBox =
                Rect.fromLTWH(leftX + labelW + 8.0, currentY - 2.0, 120.0, 30.0);
          } else {
            pos = BlankPosition.below;
            blankBox = Rect.fromLTWH(
                leftX, currentY + labelH + 6.0, labelW + 40.0, 30.0);
          }
        } else {
          pos = BlankPosition.below;
          blankBox = Rect.fromLTWH(
            leftX,
            currentY + labelH + 6.0,
            math.max(labelW + 30.0, 160.0),
            32.0,
          );
        }

        // Weak OCR matches → mark blank unclear so UI shows red guidance
        if (match.confidence < 0.72) {
          pos = BlankPosition.unclear;
          blankBox = null;
        }

        final conf = confidenceFromScore(
          match.confidence,
          blankPosition: pos,
        );

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
