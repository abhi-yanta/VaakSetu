import 'package:flutter_test/flutter_test.dart';
import 'package:vaaksetu_mobile/domain/models/form_field_model.dart';
import 'package:vaaksetu_mobile/domain/rules/form_field_engine.dart';

void main() {
  group('FormFieldEngine Tests', () {
    test('Levenshtein distance calculation is accurate', () {
      expect(FormFieldEngine.levenshteinDistance('name', 'name'), 0);
      expect(FormFieldEngine.levenshteinDistance('name', 'nme'), 1);
      expect(FormFieldEngine.levenshteinDistance('kitten', 'sitting'), 3);
    });

    test('stringSimilarity produces normalized ratio', () {
      expect(FormFieldEngine.stringSimilarity('mobile number', 'mobile number'), 1.0);
      expect(FormFieldEngine.stringSimilarity('mobile', 'mbile'), greaterThan(0.75));
    });

    test('parseDocumentToFormFields extracts and orders registration fields', () {
      const sampleText = '''
Government Welfare Registration Form
1. Full Name / पूरा नाम: Ramesh Kumar
2. Date of Birth / जन्म तिथि: 15/08/1982
3. Mobile Number / मोबाइल नंबर: 9876543210
4. Residential Address / स्थायी पता: Village Rampur
5. Applicant Signature / हस्ताक्षर:
''';

      final fields = FormFieldEngine.parseDocumentToFormFields(
        rawText: sampleText,
        langCode: 'hi',
        docWidth: 400,
        docHeight: 700,
      );

      expect(fields.isNotEmpty, isTrue);
      final keys = fields.map((f) => f.fieldKey).toList();

      expect(keys.contains('name'), isTrue);
      expect(keys.contains('dob'), isTrue);
      expect(keys.contains('phone'), isTrue);
      expect(keys.contains('signature'), isTrue);

      // Verify reading order is sequential starting at 1
      for (int i = 0; i < fields.length; i++) {
        expect(fields[i].readingOrder, i + 1);
      }
    });

    test('Detects blank position and assigns green/yellow confidence', () {
      const sampleText = '''
Full Name:
Signature of Applicant:
''';

      final fields = FormFieldEngine.parseDocumentToFormFields(
        rawText: sampleText,
        langCode: 'en',
      );

      final sigField = fields.firstWhere((f) => f.fieldKey == 'signature');
      expect(sigField.blankPosition, BlankPosition.below);
      expect(sigField.confidence, FieldConfidence.green);
    });
  });
}
