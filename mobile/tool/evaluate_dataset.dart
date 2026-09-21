import 'dart:convert';
import 'dart:io';
import 'package:vaaksetu_mobile/domain/models/document_analysis.dart';
import 'package:vaaksetu_mobile/domain/rules/rule_engine.dart';

void main() {
  final jsonFile = File('data/vaaksetu_dataset.json');
  if (!jsonFile.existsSync()) {
    print('Dataset file not found at data/vaaksetu_dataset.json');
    return;
  }

  final List<dynamic> records = jsonDecode(jsonFile.readAsStringSync());
  print('====================================================');
  print('Evaluating VaakSetu RuleEngine against ${records.length} samples...');
  print('====================================================\n');

  int total = records.length;
  int categoryMatches = 0;
  int riskMatches = 0;

  int legalTruePositive = 0;
  int legalFalsePositive = 0;
  int legalTrueNegative = 0;
  int legalFalseNegative = 0;

  for (var record in records) {
    final text = record['text'] as String;
    final expectedCategory = record['category'] as String;
    final expectedRisk = record['risk_level'] as String;
    final isLegal = record['is_legal_document'] as bool;

    final analysis = RuleEngine.analyze(text);
    final actualCategory = analysis.category.name;
    final actualRisk = analysis.severity.name;

    // Check category match
    if (actualCategory == expectedCategory) {
      categoryMatches++;
    }

    // Check risk match
    if (actualRisk == expectedRisk) {
      riskMatches++;
    }

    // Legal vs Non-legal classification
    final predictedAsLegal = actualCategory != 'unrecognized' && actualCategory != 'unclear';
    if (isLegal && predictedAsLegal) {
      legalTruePositive++;
    } else if (!isLegal && predictedAsLegal) {
      legalFalsePositive++;
    } else if (!isLegal && !predictedAsLegal) {
      legalTrueNegative++;
    } else if (isLegal && !predictedAsLegal) {
      legalFalseNegative++;
    }
  }

  final catAcc = (categoryMatches / total) * 100;
  final riskAcc = (riskMatches / total) * 100;

  final precision = legalTruePositive / (legalTruePositive + legalFalsePositive);
  final recall = legalTruePositive / (legalTruePositive + legalFalseNegative);
  final f1 = 2 * (precision * recall) / (precision + recall);

  print('RESULTS SUMMARY:');
  print('  • Total Samples: $total');
  print('  • Category Accuracy: ${catAcc.toStringAsFixed(1)}% ($categoryMatches / $total)');
  print('  • Risk Severity Accuracy: ${riskAcc.toStringAsFixed(1)}% ($riskMatches / $total)');
  print('\nLEGAL DOCUMENT DISCRIMINATION (Legal vs Non-Legal):');
  print('  • True Positives (Legal recognized): $legalTruePositive');
  print('  • False Positives (Non-legal mislabeled as legal): $legalFalsePositive');
  print('  • True Negatives (Non-legal rejected): $legalTrueNegative');
  print('  • False Negatives (Legal rejected): $legalFalseNegative');
  print('  • Legal Precision: ${(precision * 100).toStringAsFixed(1)}%');
  print('  • Legal Recall: ${(recall * 100).toStringAsFixed(1)}%');
  print('  • F1 Score: ${(f1 * 100).toStringAsFixed(1)}%');
  print('====================================================');
}
