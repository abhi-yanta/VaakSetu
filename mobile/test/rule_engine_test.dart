import 'package:flutter_test/flutter_test.dart';
import 'package:vaaksetu_mobile/domain/models/document_analysis.dart';
import 'package:vaaksetu_mobile/domain/rules/rule_engine.dart';
import 'package:vaaksetu_mobile/data/services/preset_service.dart';

void main() {
  group('RuleEngine Tests', () {
    test('Correctly rejects non-legal notebook handwritten text as UNRECOGNIZED', () {
      const notebookText =
          'Question (12): Define an array. Explain the 1-D, 2-D and multidimensional arrays with suitable examples. '
          'Answer: Array: It is a linear collection of elements stored at contiguous memory locations.';

      final analysis = RuleEngine.analyze(notebookText);

      expect(analysis.category, equals(DocumentCategory.unrecognized));
      expect(analysis.severity, equals(DocumentSeverity.unknown));
      expect(analysis.warningKeys, contains('info_non_legal_document'));
      expect(analysis.isSafe, isFalse);
      expect(analysis.isUnrecognized, isTrue);
    });

    test('Classifies blank or insufficient text as UNCLEAR', () {
      const shortText = 'Hi test';
      final analysis = RuleEngine.analyze(shortText);

      expect(analysis.category, equals(DocumentCategory.unclear));
      expect(analysis.severity, equals(DocumentSeverity.unknown));
      expect(analysis.warningKeys, contains('alert_unclear_image'));
    });

    test('Identifies predatory loan with high interest and land collateral as DANGER', () {
      final loanText = PresetService.presets[0].fullText;
      final analysis = RuleEngine.analyze(loanText);

      expect(analysis.category, equals(DocumentCategory.loan));
      expect(analysis.severity, equals(DocumentSeverity.danger));
      expect(analysis.warningKeys, contains('alert_high_interest'));
      expect(analysis.warningKeys, contains('alert_collateral'));
      expect(analysis.warningKeys, contains('alert_hidden_fee'));
    });

    test('Identifies standard land deed with mutual consent as SAFE', () {
      final deedText = PresetService.presets[1].fullText;
      final analysis = RuleEngine.analyze(deedText);

      expect(analysis.category, equals(DocumentCategory.deed));
      expect(analysis.severity, equals(DocumentSeverity.safe));
      expect(analysis.warningKeys, isEmpty);
    });

    test('Identifies exploitative labor contract with unpaid overtime and bond as DANGER', () {
      final jobText = PresetService.presets[2].fullText;
      final analysis = RuleEngine.analyze(jobText);

      expect(analysis.category, equals(DocumentCategory.job));
      expect(analysis.severity, equals(DocumentSeverity.danger));
      expect(analysis.warningKeys, contains('alert_unpaid_labor'));
      expect(analysis.warningKeys, contains('alert_no_exit'));
    });

    test('Identifies hospital negligence waiver as WARNING', () {
      final medicalText = PresetService.presets[3].fullText;
      final analysis = RuleEngine.analyze(medicalText);

      expect(analysis.category, equals(DocumentCategory.medical));
      expect(analysis.severity, equals(DocumentSeverity.warning));
      expect(analysis.warningKeys, contains('alert_medical_liability'));
    });

    test('Identifies Hindi Devanagari keywords in loan documents', () {
      const hindiLoan = 'ऋण समझौता। ब्याज 36% प्रति वर्ष चक्रवृद्धि। भूमि गिरवी रखी जाएगी।';
      final analysis = RuleEngine.analyze(hindiLoan);

      expect(analysis.category, equals(DocumentCategory.loan));
      expect(analysis.severity, equals(DocumentSeverity.danger));
      expect(analysis.warningKeys, contains('alert_high_interest'));
      expect(analysis.warningKeys, contains('alert_collateral'));
    });
  });
}
