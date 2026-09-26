class DocumentPreset {
  final String id;
  final String title;
  final String previewDescription;
  final String fullText;
  final bool isForm;

  const DocumentPreset({
    required this.id,
    required this.title,
    required this.previewDescription,
    required this.fullText,
    this.isForm = false,
  });
}

class PresetService {
  /// Demo corpus: form presets (isForm:true) mirror RuleEngine legal presets —
  /// bilingual OCR-like samples used as the "training / evaluation" set for
  /// FormFieldEngine dictionary matching (not a neural net).
  static const List<DocumentPreset> presets = [
    DocumentPreset(
      id: 'kisan_welfare_form',
      title: '📝 Kisan Kalyan Registration Form (Form Guide)',
      previewDescription: 'Government welfare scheme beneficiary form with bilingual labels',
      isForm: true,
      fullText:
          'Government Welfare Registration Form\n'
          'Personal Details / व्यक्तिगत विवरण\n'
          '1. Full Name / पूरा नाम: Ramesh Kumar\n'
          '2. Father\'s Name / पिता का नाम: Suresh Kumar\n'
          '3. Date of Birth / जन्म तिथि: 15/08/1982\n'
          '4. Age / आयु: 43\n'
          '5. Gender / लिंग: Male\n'
          '6. Category / श्रेणी: OBC\n'
          '7. Mobile Number / मोबाइल नंबर: 9876543210\n'
          '8. Aadhaar Number / आधार संख्या: 1234 5678 9012\n'
          '9. Residential Address / निवास का पता: Village Rampur, District Varanasi, UP\n'
          '10. Village / गाँव: Rampur\n'
          '11. District / जिला: Varanasi\n'
          '12. PIN Code / पिन कोड: 221001\n'
          '13. Annual Income / वार्षिक आय: 85000\n'
          '14. Date / दिनांक: 23/09/2026\n'
          '15. Applicant Signature / हस्ताक्षर / अंगूठे का निशान: [Sign Here]',
    ),
    DocumentPreset(
      id: 'scholarship_form',
      title: '📝 Rural Youth Scholarship Form (Form Guide)',
      previewDescription: 'Student scholarship application with education & family fields',
      isForm: true,
      fullText:
          'National Student Welfare Council Scholarship Application Form\n'
          'Applicant Details / आवेदक विवरण\n'
          'Applicant Name / विद्यार्थी का नाम:\n'
          'Father\'s Name / पिता का नाम:\n'
          'Mother\'s Name / माता का नाम:\n'
          'Date of Birth / जन्म तिथि:\n'
          'Gender / लिंग:\n'
          'Category / जाति श्रेणी:\n'
          'Mobile Number / मोबाइल नंबर:\n'
          'Email / ईमेल:\n'
          'Educational Qualification / शैक्षणिक योग्यता:\n'
          'Identity Number / पहचान पत्र:\n'
          'Permanent Address / स्थायी पता:\n'
          'PIN Code / पिन कोड:\n'
          'Annual Family Income / पारिवारिक आय:\n'
          'Date / दिनांक:\n'
          'Signature of Applicant / हस्ताक्षर:',
    ),
    DocumentPreset(
      id: 'ration_card_form',
      title: '📝 Ration Card Application Form (Form Guide)',
      previewDescription: 'PDS ration card bilingual registration layout',
      isForm: true,
      fullText:
          'Public Distribution System — Ration Card Application Form\n'
          'राशन कार्ड आवेदन पत्र\n'
          '1. Full Name / पूरा नाम:\n'
          '2. Father\'s Name / पिता का नाम:\n'
          '3. Mother\'s Name / माता का नाम:\n'
          '4. Date of Birth / जन्म तिथि:\n'
          '5. Age / उम्र:\n'
          '6. Gender / लिंग:\n'
          '7. Marital Status / वैवाहिक स्थिति:\n'
          '8. Occupation / व्यवसाय:\n'
          '9. Mobile Number / मोबाइल नंबर:\n'
          '10. Aadhaar Number / आधार नंबर:\n'
          '11. Address / पता:\n'
          '12. Village / गाँव:\n'
          '13. District / जिला:\n'
          '14. PIN Code / पिन कोड:\n'
          '15. Category / श्रेणी:\n'
          '16. Annual Income / वार्षिक आय:\n'
          '17. Date / दिनांक:\n'
          '18. Signature / Thumb Impression / हस्ताक्षर / अंगूठे का निशान:',
    ),
    DocumentPreset(
      id: 'bank_kyc_form',
      title: '📝 Bank Account KYC Form (Form Guide)',
      previewDescription: 'Bank KYC-style form with account, IFSC, and ID fields',
      isForm: true,
      fullText:
          'Bank Customer KYC / Account Opening Form\n'
          'बैंक केवाईसी / खाता खोलने का फॉर्म\n'
          'Personal Details / व्यक्तिगत विवरण\n'
          'Account Holder Name / खाताधारक का नाम:\n'
          'Father\'s Name / पिता का नाम:\n'
          'Date of Birth / जन्म तिथि:\n'
          'Gender / लिंग:\n'
          'Marital Status / वैवाहिक स्थिति:\n'
          'Mobile Number / मोबाइल नंबर:\n'
          'Email ID / ईमेल आईडी:\n'
          'Aadhaar Number / आधार संख्या:\n'
          'PAN / Identity Number / पहचान पत्र:\n'
          'Occupation / पेशा:\n'
          'Permanent Address / स्थायी पता:\n'
          'PIN Code / पिन कोड:\n'
          'Bank Details / बैंक विवरण\n'
          'Bank Account Number / बैंक खाता संख्या:\n'
          'IFSC Code / आईएफएससी कोड:\n'
          'Date / दिनांक:\n'
          'Applicant Signature / हस्ताक्षर:',
    ),
    DocumentPreset(
      id: 'job_application_form',
      title: '📝 Job Application Form (Form Guide)',
      previewDescription: 'Employment application with education and contact fields',
      isForm: true,
      fullText:
          'Employment / Job Application Form\n'
          'नौकरी आवेदन पत्र\n'
          '1. Candidate Name / उम्मीदवार का नाम:\n'
          '2. Father\'s Name / पिता का नाम:\n'
          '3. Date of Birth / जन्म तिथि:\n'
          '4. Age / आयु:\n'
          '5. Gender / लिंग:\n'
          '6. Category / आरक्षण श्रेणी:\n'
          '7. Mobile Number / मोबाइल नंबर:\n'
          '8. Email / ईमेल:\n'
          '9. Educational Qualification / शैक्षणिक योग्यता:\n'
          '10. Occupation / वर्तमान व्यवसाय:\n'
          '11. Aadhaar / ID Number / आधार / पहचान संख्या:\n'
          '12. Permanent Address / स्थायी पता:\n'
          '13. District / जिला:\n'
          '14. PIN Code / पिन कोड:\n'
          '15. Date of Application / आवेदन की तिथि:\n'
          '16. Signature of Applicant / आवेदक के हस्ताक्षर:',
    ),
    DocumentPreset(
      id: 'loan_fraud',
      title: '36% High-Interest Loan (High Risk)',
      previewDescription: 'Private moneylender loan with land seizure clause',
      fullText:
          'Loan Agreement. The borrower agrees to borrow Rs. 50,000. '
          'The interest rate is 3% per month (compound interest, 36% per annum). '
          'In case of default, the lender has complete rights to seize and mortgage '
          'the borrower agricultural land survey number 405. '
          'Processing fee of Rs. 5,000 will be deducted in advance.',
    ),
    DocumentPreset(
      id: 'land_deed_safe',
      title: 'Standard Land Sale Deed (Safe)',
      previewDescription: 'Mutually consented property deed with tax receipts',
      fullText:
          'Sale Deed. This document confirms the sale of plot 42 from seller Ramesh '
          'to buyer Suresh for Rs. 3,00,000. All government taxes and registration fees '
          'have been paid. Both parties sign with mutual consent in front of legal witnesses.',
    ),
    DocumentPreset(
      id: 'labor_bond',
      title: 'Exploitative Labor Contract (High Risk)',
      previewDescription: 'Mandatory 12-hour shifts, unpaid overtime, heavy bond penalty',
      fullText:
          'Labor Contract. Employee agrees to work 12 hours daily. '
          'Overtime without pay is mandatory during peak harvest season. '
          'Employee cannot resign or leave the work site before 12 months under bond period. '
          'Any early resignation incurs a penalty fee of Rs. 25,000.',
    ),
    DocumentPreset(
      id: 'medical_waiver',
      title: 'Hospital Surgery Release Form (Warning)',
      previewDescription: 'Broad liability and negligence waiver clause',
      fullText:
          'Patient Consent Form. Patient agrees to undergo surgical procedure. '
          'The hospital and doctors are not responsible for any post-surgery complications, '
          'medical negligence, or accidental outcomes. '
          'Patient waives liability and rights to file claims against hospital staff at own risk.',
    ),
  ];

  static List<DocumentPreset> getPresets() => presets;

  /// Form-only demo samples (Form Guide mode).
  static List<DocumentPreset> getFormPresets() =>
      presets.where((p) => p.isForm).toList();
}
