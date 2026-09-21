export const DOCUMENT_CATEGORIES = {
  LOAN: 'loan',
  DEED: 'deed',
  JOB: 'job',
  MEDICAL: 'medical',
  UNRECOGNIZED: 'unrecognized',
  UNCLEAR: 'unclear'
};

export const SEVERITIES = {
  SAFE: 'safe',
  WARNING: 'warning',
  DANGER: 'danger',
  UNKNOWN: 'unknown'
};

const legalMarkers = [
  'agreement', 'contract', 'affidavit', 'notary', 'witness', 'witnesses',
  'party', 'parties', 'signature', 'signed', 'terms and conditions', 'clause',
  'clauses', 'stamp paper', 'hereby', 'whereas', 'undertaking', 'deed',
  'अनुबंध', 'करार', 'दस्तावेज़', 'हस्ताक्षर', 'शर्तें', 'साक्षी', 'शपथ पत्र',
  'ஒப்பந்தம்', 'கையொப்பம்', 'నిబంధనలు', 'సంతకం'
];

const deedKeywords = [
  'sale deed', 'conveyance deed', 'title deed', 'gift deed', 'lease deed',
  'khasra', 'khatauni', 'khata', 'survey number', 'sub-registrar', 'registrar',
  'registration', 'registra', 'tehsil', 'mauza', 'patta', 'property', 'plot',
  'boundaries', 'land', 'खसरा', 'खतौनी', 'पट्टा', 'पंजीकरण', 'भूमि', 'जमीन',
  'बिक्री पत्र', 'तहसील', 'चौहद्दी', 'பத்திரம்', 'நிலம்', 'రిజిస్ట్రేషన్', 'భూమి'
];

const loanKeywords = [
  'loan', 'loan agreement', 'borrower', 'lender', 'creditor', 'debtor',
  'principal amount', 'interest rate', 'emi', 'installment', 'repayment',
  'sanction', 'default', 'collateral', 'mortgage', 'promissory', 'pledge',
  'ऋण', 'कर्ज', 'ऋण समझौता', 'ब्याज', 'उधार', 'किस्त', 'गिरवी', 'जब्त',
  'கடன்', 'வட்டி', 'అప్పు', 'వడ్డీ'
];

const jobKeywords = [
  'employment', 'appointment letter', 'employee', 'employer', 'salary',
  'wages', 'remuneration', 'probation', 'work hours', 'working hours',
  'overtime', 'resignation', 'resign', 'termination', 'bond period',
  'labor contract', 'नौकरी', 'रोजगार', 'काम', 'वेतन', 'मजदूरी', 'नियोक्ता',
  'कर्मचारी', 'काम के घंटे', 'வேலை', 'சம்பளம்', 'ఉద్యోగం', 'జీతం'
];

const medicalKeywords = [
  'medical', 'hospital', 'consent form', 'patient', 'doctor', 'surgery',
  'surgical', 'clinical', 'treatment', 'diagnosis', 'anesthesia', 'discharged',
  'admission', 'liability waiver', 'मरीज', 'अस्पताल', 'इलाज', 'डॉक्टर',
  'सहमति पत्र', 'शल्य चिकित्सा', 'चिकित्सा', 'சிகிச்சை', 'மருத்துவமனை', 'చికిత్స', 'ఆసుపత్రి'
];

function matchesKeyword(text, keyword) {
  const isAscii = /^[a-zA-Z0-9\s\-]+$/.test(keyword);
  if (isAscii) {
    const pattern = new RegExp('\\b' + keyword.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + '\\b', 'i');
    return pattern.test(text);
  }
  return text.includes(keyword);
}

function countMatches(text, keywords) {
  let count = 0;
  for (const kw of keywords) {
    if (matchesKeyword(text, kw)) count++;
  }
  return count;
}

export function analyzeDocumentText(text = "") {
  const trimmed = text.trim();
  const normalizedText = trimmed.toLowerCase();

  // 1. Check for insufficient text (blank page, dark photo, unreadable handwriting)
  if (trimmed.length < 20 || trimmed.split(/\s+/).length < 4) {
    return {
      category: DOCUMENT_CATEGORIES.UNCLEAR,
      severity: SEVERITIES.UNKNOWN,
      warnings: ['alert_unclear_image'],
      rawTextLength: text.length
    };
  }

  // 2. Score against categories using word boundaries
  const legalScore = countMatches(normalizedText, legalMarkers);
  const loanScore = countMatches(normalizedText, loanKeywords);
  const deedScore = countMatches(normalizedText, deedKeywords);
  const jobScore = countMatches(normalizedText, jobKeywords);
  const medicalScore = countMatches(normalizedText, medicalKeywords);

  const totalScore = legalScore + loanScore + deedScore + jobScore + medicalScore;

  // 3. If no official/legal markers are present, classify as UNRECOGNIZED (e.g. school notebook, random notes)
  if (totalScore === 0 || (loanScore === 0 && deedScore === 0 && jobScore === 0 && medicalScore === 0 && legalScore < 2)) {
    return {
      category: DOCUMENT_CATEGORIES.UNRECOGNIZED,
      severity: SEVERITIES.UNKNOWN,
      warnings: ['info_non_legal_document'],
      rawTextLength: text.length
    };
  }

  // 4. Determine winning category
  let category = DOCUMENT_CATEGORIES.LOAN;
  let highestScore = loanScore;

  if (deedScore > highestScore) {
    category = DOCUMENT_CATEGORIES.DEED;
    highestScore = deedScore;
  }
  if (jobScore > highestScore) {
    category = DOCUMENT_CATEGORIES.JOB;
    highestScore = jobScore;
  }
  if (medicalScore > highestScore) {
    category = DOCUMENT_CATEGORIES.MEDICAL;
    highestScore = medicalScore;
  }

  if (highestScore < 1 && legalScore < 2) {
    return {
      category: DOCUMENT_CATEGORIES.UNRECOGNIZED,
      severity: SEVERITIES.UNKNOWN,
      warnings: ['info_non_legal_document'],
      rawTextLength: text.length
    };
  }

  let warnings = [];
  let severity = SEVERITIES.SAFE;

  // 5. Category specific predatory checks
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

    if (interestRate >= 24 || normalizedText.includes('30%') || normalizedText.includes('36%') || normalizedText.includes('40%') || matchesKeyword(normalizedText, 'compound interest') || normalizedText.includes('चक्रवृद्धि')) {
      warnings.push('alert_high_interest');
      severity = SEVERITIES.DANGER;
    }

    if (matchesKeyword(normalizedText, 'seize') || matchesKeyword(normalizedText, 'collateral') || matchesKeyword(normalizedText, 'forfeit') || matchesKeyword(normalizedText, 'mortgage') || normalizedText.includes('guarantee land') || normalizedText.includes('गिरवी') || normalizedText.includes('जब्त') || normalizedText.includes('அடமானம்')) {
      warnings.push('alert_collateral');
      severity = SEVERITIES.DANGER;
    }

    if (normalizedText.includes('processing fee') || normalizedText.includes('admin fee') || normalizedText.includes('hidden cost') || matchesKeyword(normalizedText, 'commission') || normalizedText.includes('कमीशन')) {
      warnings.push('alert_hidden_fee');
      if (severity !== SEVERITIES.DANGER) severity = SEVERITIES.WARNING;
    }
  }

  if (category === DOCUMENT_CATEGORIES.DEED) {
    if (normalizedText.includes('transfer all rights') || matchesKeyword(normalizedText, 'irrevocable') || matchesKeyword(normalizedText, 'relinquish') || normalizedText.includes('अधिकार हस्तांतरण')) {
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
