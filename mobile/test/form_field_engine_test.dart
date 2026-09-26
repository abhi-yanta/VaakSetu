import 'package:flutter_test/flutter_test.dart';
import 'package:vaaksetu_mobile/data/services/preset_service.dart';
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

    test('tokenOverlap rewards shared multi-word labels', () {
      expect(
        FormFieldEngine.tokenOverlap('full name', 'applicant full name'),
        greaterThan(0.5),
      );
      expect(
        FormFieldEngine.tokenOverlap('bank account number', 'account number'),
        greaterThan(0.4),
      );
    });

    test('stripLineNumber and labelPortion isolate fillable labels', () {
      expect(
        FormFieldEngine.stripLineNumber('1. Full Name / पूरा नाम: Ramesh'),
        'Full Name / पूरा नाम: Ramesh',
      );
      expect(
        FormFieldEngine.labelPortion('12. PIN Code / पिन कोड: 221001'),
        'PIN Code / पिन कोड',
      );
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

    test('Distinguishes father_name from applicant name', () {
      const sampleText = '''
Full Name / पूरा नाम:
Father's Name / पिता का नाम:
Mother's Name / माता का नाम:
''';

      final fields = FormFieldEngine.parseDocumentToFormFields(
        rawText: sampleText,
        langCode: 'hi',
      );
      final keys = fields.map((f) => f.fieldKey).toSet();

      expect(keys.contains('name'), isTrue);
      expect(keys.contains('father_name'), isTrue);
      expect(keys.contains('mother_name'), isTrue);
    });

    test('Detects age, email, pincode as separate fields from dob/address', () {
      const sampleText = '''
Date of Birth / जन्म तिथि:
Age / आयु:
Email / ईमेल:
Permanent Address / स्थायी पता:
PIN Code / पिन कोड:
''';

      final fields = FormFieldEngine.parseDocumentToFormFields(
        rawText: sampleText,
        langCode: 'hi',
      );
      final keys = fields.map((f) => f.fieldKey).toSet();

      expect(keys.contains('dob'), isTrue);
      expect(keys.contains('age'), isTrue);
      expect(keys.contains('email'), isTrue);
      expect(keys.contains('address'), isTrue);
      expect(keys.contains('pincode'), isTrue);
    });

    test('looksLikeForm is true for registration forms and false for prose', () {
      expect(
        FormFieldEngine.looksLikeForm(
          'Government Welfare Registration Form\nFull Name:\nMobile Number:\n',
        ),
        isTrue,
      );
      expect(
        FormFieldEngine.looksLikeForm(
          'Once upon a time there was a quiet village near the river.',
        ),
        isFalse,
      );
    });

    test('confidenceFromScore maps green / yellow / red meaningfully', () {
      expect(
        FormFieldEngine.confidenceFromScore(
          0.95,
          blankPosition: BlankPosition.below,
        ),
        FieldConfidence.green,
      );
      expect(
        FormFieldEngine.confidenceFromScore(
          0.80,
          blankPosition: BlankPosition.right,
        ),
        FieldConfidence.yellow,
      );
      expect(
        FormFieldEngine.confidenceFromScore(
          0.90,
          blankPosition: BlankPosition.unclear,
        ),
        FieldConfidence.red,
      );
    });

    test('All isForm presets yield multiple detected fields', () {
      final formPresets = PresetService.getFormPresets();
      expect(formPresets.length, greaterThanOrEqualTo(5));

      for (final preset in formPresets) {
        expect(preset.isForm, isTrue);
        final fields = FormFieldEngine.parseDocumentToFormFields(
          rawText: preset.fullText,
          langCode: 'hi',
        );
        expect(
          fields.length,
          greaterThanOrEqualTo(5),
          reason: '${preset.id} should detect ≥5 fields, got ${fields.length}',
        );
        expect(FormFieldEngine.looksLikeForm(preset.fullText), isTrue);
      }
    });

    test('Bank KYC preset detects bank_account and ifsc', () {
      final kyc = PresetService.presets.firstWhere((p) => p.id == 'bank_kyc_form');
      final fields = FormFieldEngine.parseDocumentToFormFields(
        rawText: kyc.fullText,
        langCode: 'en',
      );
      final keys = fields.map((f) => f.fieldKey).toSet();

      expect(keys.contains('bank_account'), isTrue);
      expect(keys.contains('ifsc'), isTrue);
      expect(keys.contains('email'), isTrue);
      expect(keys.contains('name'), isTrue);
    });

    test('Ration card preset detects marital_status and village', () {
      final ration =
          PresetService.presets.firstWhere((p) => p.id == 'ration_card_form');
      final fields = FormFieldEngine.parseDocumentToFormFields(
        rawText: ration.fullText,
        langCode: 'hi',
      );
      final keys = fields.map((f) => f.fieldKey).toSet();

      expect(keys.contains('marital_status'), isTrue);
      expect(keys.contains('village'), isTrue);
      expect(keys.contains('district'), isTrue);
      expect(keys.contains('category'), isTrue);
    });

    test('Dictionary covers core Indian registration fields', () {
      final keys = FormFieldDictionary.definitions.keys.toSet();
      for (final required in [
        'name',
        'father_name',
        'mother_name',
        'dob',
        'age',
        'gender',
        'phone',
        'email',
        'address',
        'pincode',
        'village',
        'district',
        'id_number',
        'bank_account',
        'ifsc',
        'income',
        'category',
        'occupation',
        'education',
        'marital_status',
        'signature',
        'date',
      ]) {
        expect(keys.contains(required), isTrue, reason: 'missing $required');
      }
    });

    test('Hindi labels resolve for selectedLang', () {
      final match = FormFieldEngine.matchLine('मोबाइल नंबर:', 'hi');
      expect(match, isNotNull);
      expect(match!.fieldKey, 'phone');
      expect(match.translatedLabel, contains('मोबाइल'));
    });
  });
}
