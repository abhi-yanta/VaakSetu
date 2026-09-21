import 'dart:convert';
import 'dart:io';
import 'dart:math';

void main() {
  final random = Random(42);
  final List<Map<String, dynamic>> dataset = [];

  print('Generating VaakSetu Synthetic Legal & Non-Legal ML Dataset...');

  // 1. Predatory Loans (Danger)
  final loanLenders = [
    'Shree Ganesh Finance',
    'Chaudhary Moneylenders',
    'Local Rural Credit Union',
    'Sethji Private Finance',
    'Kisan Quick Cash'
  ];
  final interestRates = [30, 36, 48, 60, 72];
  final landClauses = [
    'The lender holds unconditional rights to seize and take possession of agricultural land survey no. {survey} without court notice.',
    'Lender can forfeit borrower ancestral property without arbitration.',
    'Borrower pledges farm land khasra no. {survey} as direct liquidation collateral.'
  ];
  final advanceFees = [2000, 5000, 7500, 10000];

  for (int i = 0; i < 20; i++) {
    final lender = loanLenders[random.nextInt(loanLenders.length)];
    final rate = interestRates[random.nextInt(interestRates.length)];
    final fee = advanceFees[random.nextInt(advanceFees.length)];
    final survey = 100 + random.nextInt(900);
    final clause = landClauses[random.nextInt(landClauses.length)].replaceAll('{survey}', survey.toString());

    dataset.add({
      'id': 'loan_danger_${i + 1}',
      'category': 'loan',
      'is_legal_document': true,
      'risk_level': 'danger',
      'language': 'en',
      'text':
          'Loan Agreement. Between $lender (Lender) and Borrower. The borrower agrees to borrow Rs. 50,000. '
          'The interest rate is $rate% per annum compounded monthly. $clause '
          'An advance processing deduction fee of Rs. $fee shall be withheld prior to disbursement. '
          'Borrower surrenders three signed blank cheques as guarantee.',
      'expected_warnings': ['predatory_interest', 'land_collateral', 'advance_fee', 'blank_cheque'],
    });
  }

  // 2. Safe Loans (Safe)
  for (int i = 0; i < 15; i++) {
    final rate = 9 + random.nextInt(6); // 9% to 14%
    dataset.add({
      'id': 'loan_safe_${i + 1}',
      'category': 'loan',
      'is_legal_document': true,
      'risk_level': 'safe',
      'language': 'en',
      'text':
          'Official Bank Loan Contract. Between National Rural Bank and Borrower. '
          'Sanctioned principal amount Rs. 1,00,000. Simple interest rate of $rate% per annum with 36 monthly EMIs. '
          'No collateral required under government credit guarantee scheme. '
          'Prepayment penalty is zero. Fully compliant with RBI Fair Practices Code.',
      'expected_warnings': [],
    });
  }

  // 3. Land Deeds (Safe & Warning)
  for (int i = 0; i < 15; i++) {
    final plot = 10 + random.nextInt(80);
    final amount = (2 + random.nextInt(8)) * 100000;
    dataset.add({
      'id': 'deed_safe_${i + 1}',
      'category': 'deed',
      'is_legal_document': true,
      'risk_level': 'safe',
      'language': 'en',
      'text':
          'Registered Sale Deed. This irrevocable agreement of sale is executed on stamp paper for plot no. $plot, '
          'measuring 1200 sq ft, for total consideration of Rs. $amount. '
          'Both seller and buyer execute this deed with mutual consent in the presence of two independent witnesses. '
          'Stamp duty and municipal registration tax receipts are duly attached.',
      'expected_warnings': [],
    });
  }

  // 4. Exploitative Labor Contracts (Danger)
  final jobFines = [15000, 25000, 50000];
  for (int i = 0; i < 15; i++) {
    final fine = jobFines[random.nextInt(jobFines.length)];
    dataset.add({
      'id': 'job_danger_${i + 1}',
      'category': 'job',
      'is_legal_document': true,
      'risk_level': 'danger',
      'language': 'en',
      'text':
          'Employment Agreement. Worker agrees to daily duty of 12 hours minimum. '
          'Overtime without pay is mandatory during seasonal production cycles. '
          'The worker is subject to a 24-month mandatory bond period and original identification documents will be held by management. '
          'Any termination or resignation requires payment of Rs. $fine as liquidated damage penalty.',
      'expected_warnings': ['excessive_hours', 'unpaid_overtime', 'bonded_labor', 'resignation_fine'],
    });
  }

  // 5. Medical Consent & Waivers (Warning / Danger)
  for (int i = 0; i < 15; i++) {
    dataset.add({
      'id': 'medical_waiver_${i + 1}',
      'category': 'medical',
      'is_legal_document': true,
      'risk_level': 'warning',
      'language': 'en',
      'text':
          'Hospital Informed Consent and Waiver Form. Patient gives consent for laparoscopic surgical operation. '
          'The hospital, management, and treating physicians are completely absolved from all civil or criminal liability. '
          'Patient waives all rights to claim compensation or assert claims of medical negligence under any consumer forum. '
          'All risks are solely assumed by the signatory.',
      'expected_warnings': ['negligence_waiver', 'liability_release'],
    });
  }

  // 6. Hindi Devanagari Legal Documents (Loan & Deed)
  final hindiLoans = [
    {
      'id': 'hi_loan_danger_1',
      'category': 'loan',
      'risk_level': 'danger',
      'text':
          'ऋण अनुबंध पत्र। उधारकर्ता सेठ मोहनलाल साहूकार से ₹40,000 की राशि 4% मासिक चक्रवृद्धि ब्याज (48% वार्षिक) पर लेता है। '
          'किस्त न चुकाने पर साहूकार को खसरा संख्या 112 की कृषि भूमि को तुरंत ज़ब्त करने और बेचने का पूरा अधिकार होगा। '
          'अग्रिम कटौती के रूप में ₹3,000 पहले ही काट लिए गए हैं।',
    },
    {
      'id': 'hi_deed_safe_1',
      'category': 'deed',
      'risk_level': 'safe',
      'text':
          'पंजीकृत भूमि विक्रय विलेख (बैनामा)। प्रथम पक्ष रामचरण एवं द्वितीय पक्ष श्यामलाल के मध्य स्टांप पेपर पर समझौता। '
          'खसरा नंबर 204 की भूमि का पूर्ण स्वामित्व आपसी सहमति से ₹4,00,000 में हस्तांतरित किया जाता है। '
          'सभी सरकारी पंजीकरण शुल्क और कर का भुगतान हो चुका है। दोनों पक्षों के गवाहों के समक्ष हस्ताक्षर हुए।',
    },
  ];
  for (var doc in hindiLoans) {
    dataset.add({
      'id': doc['id'],
      'category': doc['category'],
      'is_legal_document': true,
      'risk_level': doc['risk_level'],
      'language': 'hi',
      'text': doc['text'],
      'expected_warnings': doc['risk_level'] == 'danger' ? ['predatory_interest', 'land_collateral'] : [],
    });
  }

  // 7. Non-Legal / General Documents (Negative Samples to Prevent False Positives)
  final nonLegalSamples = [
    {
      'id': 'non_legal_notebook_1',
      'text':
          'Question (12): Define an array. Explain the 1-D, 2-D and multidimensional arrays with suitable examples. '
          'Answer: An array is a collection of elements of the same data type stored at contiguous memory locations.',
    },
    {
      'id': 'non_legal_receipt_1',
      'text':
          'Krishna Grocery Store. Bill No: 4092. Date: 12/04/2026. '
          '1. Basmati Rice 5kg - Rs. 350. 2. Mustard Oil 1L - Rs. 160. 3. Sugar 2kg - Rs. 88. '
          'Subtotal: Rs. 598. GST: Rs. 0. Total: Rs. 598. Thank you visit again!',
    },
    {
      'id': 'non_legal_electricity_bill_1',
      'text':
          'State Power Distribution Corporation Limited. Consumer No: 8849201. Due Date: 28/09/2026. '
          'Meter Reading Units: 142 kWh. Tariff Category: Domestic Rural. Total Current Dues: Rs. 420. '
          'Pay before due date to avoid disconnection of supply.',
    },
    {
      'id': 'non_legal_letter_1',
      'text':
          'Dear Ramesh, Hope this letter finds you in good health. We celebrated Diwali with great joy in the village. '
          'Mother is doing well and sends her blessings. Please let us know when you plan to visit for the harvest season. Your loving brother.',
    },
    {
      'id': 'non_legal_homework_math_1',
      'text':
          'Class 10 Mathematics Chapter 4. Solve the quadratic equation: 2x^2 + 5x - 3 = 0. '
          'Using quadratic formula x = (-b +- sqrt(b^2 - 4ac)) / (2a). Roots are x = 1/2 and x = -3.',
    },
    {
      'id': 'non_legal_recipe_1',
      'text':
          'Masala Chai Recipe. Ingredients: 2 cups water, 1 cup milk, 2 tsp tea leaves, 1 inch crushed ginger, 2 pods cardamom, 2 tsp sugar. '
          'Boil water with ginger and spices for 3 minutes. Add milk and sugar, simmer for 2 minutes and strain.',
    },
  ];

  for (var doc in nonLegalSamples) {
    dataset.add({
      'id': doc['id'],
      'category': 'unrecognized',
      'is_legal_document': false,
      'risk_level': 'unknown',
      'language': 'en',
      'text': doc['text'],
      'expected_warnings': [],
    });
  }

  // Create data directory
  final dataDir = Directory('data');
  if (!dataDir.existsSync()) {
    dataDir.createSync(recursive: true);
  }

  // Write JSON
  final jsonFile = File('data/vaaksetu_dataset.json');
  final jsonString = const JsonEncoder.withIndent('  ').convert(dataset);
  jsonFile.writeAsStringSync(jsonString);

  // Write CSV
  final csvFile = File('data/vaaksetu_dataset.csv');
  final csvBuffer = StringBuffer();
  csvBuffer.writeln('id,category,is_legal_document,risk_level,language,text');
  for (var item in dataset) {
    final escapedText = '"${item['text'].replaceAll('"', '""')}"';
    csvBuffer.writeln('${item['id']},${item['category']},${item['is_legal_document']},${item['risk_level']},${item['language']},$escapedText');
  }
  csvFile.writeAsStringSync(csvBuffer.toString());

  print('Dataset created successfully:');
  print('  - Total records: ${dataset.length}');
  print('  - JSON Path: ${jsonFile.path}');
  print('  - CSV Path: ${csvFile.path}');
}
