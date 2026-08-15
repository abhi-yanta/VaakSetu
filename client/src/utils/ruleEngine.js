export const DOCUMENT_CATEGORIES = {
  LOAN: 'loan',
  DEED: 'deed',
  JOB: 'job',
  MEDICAL: 'medical'
};

export const SEVERITIES = {
  SAFE: 'safe',
  WARNING: 'warning',
  DANGER: 'danger'
};

export function analyzeDocumentText(text = "") {
  const normalizedText = text.toLowerCase();
  let category = DOCUMENT_CATEGORIES.LOAN;
  let warnings = [];
  let severity = SEVERITIES.SAFE;

  const deedKeywords = [
    'land', 'deed', 'property', 'survey number', 'khata', 'relinquish',
    'sale deed', 'registration', 'registra', 'plot', 'खसरा', 'पट्टा', 
    'पंजीकरण', 'भूमि', 'जमीन', 'பத்திரம்', 'நிலம்', 'రిజిస్ట్రేషన్', 'భూమి'
  ];
  
  const jobKeywords = [
    'employment', 'labor', 'job', 'salary', 'wages', 'work hours',
    'employer', 'employee', 'resign', 'overtime', 'bond', 'नौकरी', 
    'काम', 'वेतन', 'मजदूरी', 'ஒப்பந்தம்', 'வேலை', 'ఉద్యోగం', 'జీతం'
  ];

  const medicalKeywords = [
    'medical', 'hospital', 'consent', 'patient', 'treatment', 'surgery',
    'doctor', 'clinical', 'discharged', 'liability', 'मरीज', 'अस्पताल', 
    'इलाज', 'சிகிச்சை', 'மருத்துவமனை', 'చికిత్స', 'ఆసుపత్రి'
  ];

  const hasKeyword = (keywords) => keywords.some(kw => normalizedText.includes(kw));

  if (hasKeyword(deedKeywords)) {
    category = DOCUMENT_CATEGORIES.DEED;
  } else if (hasKeyword(jobKeywords)) {
    category = DOCUMENT_CATEGORIES.JOB;
  } else if (hasKeyword(medicalKeywords)) {
    category = DOCUMENT_CATEGORIES.MEDICAL;
  }

  if (category === DOCUMENT_CATEGORIES.LOAN) {
    const interestRegex = /(\d+)%\s*(?:per annum|annual|interest|yearly|interest rate|ब्याज|प्रति वर्ष)/i;
    const match = normalizedText.match(interestRegex);
    let interestRate = 0;
    
    if (match) {
      interestRate = parseInt(match[1]);
    } else {
      const monthlyMatch = normalizedText.match(/(\d+)%\s*(?:per month|monthly|प्रति माह)/i);
      if (monthlyMatch) {
        interestRate = parseInt(monthlyMatch[1]) * 12;
      }
    }

    if (interestRate >= 24 || normalizedText.includes('30%') || normalizedText.includes('36%') || normalizedText.includes('40%') || normalizedText.includes('compound interest') || normalizedText.includes('चक्रवृद्धि')) {
      warnings.push('alert_high_interest');
      severity = SEVERITIES.DANGER;
    }

    if (normalizedText.includes('seize') || normalizedText.includes('collateral') || normalizedText.includes('forfeit') || normalizedText.includes('mortgage') || normalizedText.includes('guarantee land') || normalizedText.includes('गिरवी') || normalizedText.includes('जब्त') || normalizedText.includes('அடமானம்')) {
      warnings.push('alert_collateral');
      severity = SEVERITIES.DANGER;
    }

    if (normalizedText.includes('processing fee') || normalizedText.includes('admin fee') || normalizedText.includes('hidden cost') || normalizedText.includes('commission') || normalizedText.includes('कमीशन')) {
      warnings.push('alert_hidden_fee');
      if (severity !== SEVERITIES.DANGER) severity = SEVERITIES.WARNING;
    }
  }

  if (category === DOCUMENT_CATEGORIES.DEED) {
    if (normalizedText.includes('transfer all rights') || normalizedText.includes('irrevocable') || normalizedText.includes('forever') || normalizedText.includes('relinquish') || normalizedText.includes('अधिकार हस्तांतरण')) {
      warnings.push('alert_collateral');
      severity = SEVERITIES.DANGER;
    }
    if (normalizedText.includes('without consent') || normalizedText.includes('spouse signature') || normalizedText.includes('बिना सहमति')) {
      warnings.push('alert_collateral');
      if (severity !== SEVERITIES.DANGER) severity = SEVERITIES.WARNING;
    }
  }

  if (category === DOCUMENT_CATEGORIES.JOB) {
    if (normalizedText.includes('overtime without pay') || normalizedText.includes('no overtime') || normalizedText.includes('additional hours') || normalizedText.includes('बिना अतिरिक्त भुगतान')) {
      warnings.push('alert_unpaid_labor');
      severity = SEVERITIES.DANGER;
    }
    if (normalizedText.includes('cannot resign') || normalizedText.includes('bond period') || normalizedText.includes('penalty fee') || normalizedText.includes('notice period 6 months') || normalizedText.includes('जुर्माना')) {
      warnings.push('alert_no_exit');
      if (severity !== SEVERITIES.DANGER) severity = SEVERITIES.WARNING;
    }
  }

  if (category === DOCUMENT_CATEGORIES.MEDICAL) {
    if (normalizedText.includes('not responsible') || normalizedText.includes('waive liability') || normalizedText.includes('at own risk') || normalizedText.includes('no claims') || normalizedText.includes('जिम्मेदार नहीं')) {
      warnings.push('alert_medical_liability');
      severity = SEVERITIES.WARNING;
    }
  }

  return {
    category,
    severity,
    warnings,
    rawTextLength: text.length
  };
}
