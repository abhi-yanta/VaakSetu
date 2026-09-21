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

class DocumentAnalysis {
  final DocumentCategory category;
  final DocumentSeverity severity;
  final List<String> warningKeys;
  final String rawText;
  final DateTime analyzedAt;
  final double confidenceScore;

  const DocumentAnalysis({
    required this.category,
    required this.severity,
    required this.warningKeys,
    required this.rawText,
    required this.analyzedAt,
    this.confidenceScore = 1.0,
  });

  bool get isSafe => severity == DocumentSeverity.safe;
  bool get isUnrecognized => category == DocumentCategory.unrecognized || category == DocumentCategory.unclear;
  bool get hasWarnings => warningKeys.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'category': category.name,
    'severity': severity.name,
    'warningKeys': warningKeys,
    'rawText': rawText,
    'analyzedAt': analyzedAt.toIso8601String(),
    'confidenceScore': confidenceScore,
  };

  factory DocumentAnalysis.fromJson(Map<String, dynamic> json) => DocumentAnalysis(
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
    analyzedAt: DateTime.tryParse(json['analyzedAt'] ?? '') ?? DateTime.now(),
    confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 1.0,
  );
}
