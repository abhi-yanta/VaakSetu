class DocumentPreset {
  final String id;
  final String title;
  final String previewDescription;
  final String fullText;

  const DocumentPreset({
    required this.id,
    required this.title,
    required this.previewDescription,
    required this.fullText,
  });
}

class PresetService {
  static const List<DocumentPreset> presets = [
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
}
