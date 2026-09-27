enum DocumentCategory {
  loan,
  deed,
  job,
  medical,
  unrecognized,
  unclear;

  String get key => name;
}

enum DocumentSeverity {
  safe,
  warning,
  danger,
  unknown;

  String get key => name;
}

/// A span in [DocumentAnalysis.rawText] that triggered an illegal / risky clause.
class ClauseHighlight {
  final int start;
  final int end;
  final String warningKey;
  final String matchedText;

  const ClauseHighlight({
    required this.start,
    required this.end,
    required this.warningKey,
    required this.matchedText,
  });

  Map<String, dynamic> toJson() => {
        'start': start,
        'end': end,
        'warningKey': warningKey,
        'matchedText': matchedText,
      };

  factory ClauseHighlight.fromJson(Map<String, dynamic> json) => ClauseHighlight(
        start: json['start'] as int? ?? 0,
        end: json['end'] as int? ?? 0,
        warningKey: json['warningKey'] as String? ?? '',
        matchedText: json['matchedText'] as String? ?? '',
      );
}

class DocumentAnalysis {
  final DocumentCategory category;
  final DocumentSeverity severity;
  final List<String> warningKeys;
  final String rawText;
  final DateTime analyzedAt;
  final double confidenceScore;
  /// Phrases in [rawText] that do not match a fair/legal expectation.
  final List<ClauseHighlight> highlights;

  const DocumentAnalysis({
    required this.category,
    required this.severity,
    required this.warningKeys,
    required this.rawText,
    required this.analyzedAt,
    this.confidenceScore = 1.0,
    this.highlights = const [],
  });

  bool get isSafe => severity == DocumentSeverity.safe;
  bool get isUnrecognized =>
      category == DocumentCategory.unrecognized ||
      category == DocumentCategory.unclear;
  bool get hasWarnings => warningKeys.isNotEmpty;
  bool get hasIllegalHighlights => highlights.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'category': category.name,
        'severity': severity.name,
        'warningKeys': warningKeys,
        'rawText': rawText,
        'analyzedAt': analyzedAt.toIso8601String(),
        'confidenceScore': confidenceScore,
        'highlights': highlights.map((h) => h.toJson()).toList(),
      };

  factory DocumentAnalysis.fromJson(Map<String, dynamic> json) =>
      DocumentAnalysis(
        category: DocumentCategory.values.firstWhere(
          (e) => e.name == json['category'],
          orElse: () => DocumentCategory.unrecognized,
        ),
        severity: DocumentSeverity.values.firstWhere(
          (e) => e.name == json['severity'],
          orElse: () => DocumentSeverity.unknown,
        ),
        warningKeys: List<String>.from(json['warningKeys'] ?? []),
        rawText: json['rawText'] ?? '',
        analyzedAt:
            DateTime.tryParse(json['analyzedAt'] ?? '') ?? DateTime.now(),
        confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 1.0,
        highlights: (json['highlights'] as List<dynamic>? ?? [])
            .map((e) => ClauseHighlight.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}
