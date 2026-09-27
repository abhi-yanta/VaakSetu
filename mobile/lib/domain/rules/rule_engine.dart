import '../models/document_analysis.dart';

class RuleEngine {
  // Strong official document keywords requiring exact word boundaries
  static const List<String> legalMarkers = [
    'agreement', 'contract', 'affidavit', 'notary', 'witness', 'witnesses',
    'party', 'parties', 'signature', 'signed', 'terms and conditions', 'clause',
    'clauses', 'stamp paper', 'hereby', 'whereas', 'undertaking', 'deed',
    'in favour of', 'purchaser', 'vendor', 'non judicial', 'sale deed',
    'executed', 'consideration', 'hereinafter', 'schedule', 'attestation',
    'अनुबंध', 'करार', 'दस्तावेज़', 'हस्ताक्षर', 'शर्तें', 'साक्षी', 'शपथ पत्र',
    'ஒப்பந்தம்', 'கையொப்பம்', 'నిబంధనలు', 'సంతకం'
  ];

  static const List<String> deedKeywords = [
    'sale deed', 'conveyance deed', 'title deed', 'gift deed', 'lease deed',
    'khasra', 'khatauni', 'khata', 'survey number', 'sub-registrar', 'registrar',
    'registration', 'registra', 'tehsil', 'mauza', 'patta', 'property', 'plot',
    'boundaries', 'land', 'खसरा', 'खतौनी', 'पट्टा', 'पंजीकरण', 'भूमि', 'जमीन',
    'बिक्री पत्र', 'तहसील', 'चौहद्दी', 'பத்திரம்', 'நிலம்', 'రిజిస్ట్రేషన్', 'భూమి',
    'non judicial', 'non-judicial', 'stamp paper', 'stamp duty', 'stamp certificate',
    'india non judicial', 'भारतीय गैर न्यायिक', 'indian stamp', 'e-stamp',
    'mouza', 'j.l. no', 'j.l no', 'jl no', 'decimals', 'square feet', 'sqm',
    'suti', 'murshidabad', 'dafahat', 'in favour of', 'purchaser', 'vendor',
    'total area', 'area of land', 'market value', 'total market value',
    'transferred', 'hereinafter', 'west bengal', 'sub registrar', 'district',
  ];

  static const List<String> loanKeywords = [
    'loan', 'loan agreement', 'borrower', 'lender', 'creditor', 'debtor',
    'principal amount', 'interest rate', 'emi', 'installment', 'repayment',
    'sanction', 'default', 'collateral', 'mortgage', 'promissory', 'pledge',
    'ऋण', 'कर्ज', 'ऋण समझौता', 'ब्याज', 'उधार', 'किस्त', 'गिरवी', 'जब्त',
    'கடன்', 'வட்டி', 'అప్పు', 'వడ్డీ'
  ];

  static const List<String> jobKeywords = [
    'employment', 'appointment letter', 'employee', 'employer', 'salary',
    'wages', 'remuneration', 'probation', 'work hours', 'working hours',
    'overtime', 'resignation', 'resign', 'termination', 'bond period',
    'labor contract', 'नौकरी', 'रोजगार', 'काम', 'वेतन', 'मजदूरी', 'नियोक्ता',
    'कर्मचारी', 'काम के घंटे', 'வேலை', 'சம்பளம்', 'ఉద్యోగం', 'జీతం'
  ];

  static const List<String> medicalKeywords = [
    'medical', 'hospital', 'consent form', 'patient', 'doctor', 'surgery',
    'surgical', 'clinical', 'treatment', 'diagnosis', 'anesthesia', 'discharged',
    'admission', 'liability waiver', 'मरीज', 'अस्पताल', 'इलाज', 'डॉक्टर',
    'सहमति पत्र', 'शल्य चिकित्सा', 'चिकित्सा', 'சிகிச்சை', 'மருத்துவமனை', 'చికిత్స', 'ఆసుపత్రి'
  ];

  static bool _matchesKeyword(String text, String keyword) {
    final isAscii = RegExp(r'^[a-zA-Z0-9\s\-]+$').hasMatch(keyword);
    if (isAscii) {
      final pattern = r'\b' + RegExp.escape(keyword) + r'\b';
      return RegExp(pattern, caseSensitive: false).hasMatch(text);
    }
    return text.contains(keyword);
  }

  static int _countMatches(String text, List<String> keywords) {
    int count = 0;
    for (final kw in keywords) {
      if (_matchesKeyword(text, kw)) count++;
    }
    return count;
  }

  /// Find [needle] in [original] (case-insensitive for Latin), return highlight or null.
  static ClauseHighlight? _findHighlight(
    String original,
    String needle,
    String warningKey,
  ) {
    if (needle.trim().isEmpty) return null;
    final lowerOrig = original.toLowerCase();
    final lowerNeedle = needle.toLowerCase();
    var idx = lowerOrig.indexOf(lowerNeedle);
    if (idx < 0) {
      // Try original script needle as-is
      idx = original.indexOf(needle);
      if (idx < 0) return null;
      return ClauseHighlight(
        start: idx,
        end: idx + needle.length,
        warningKey: warningKey,
        matchedText: original.substring(idx, idx + needle.length),
      );
    }
    return ClauseHighlight(
      start: idx,
      end: idx + needle.length,
      warningKey: warningKey,
      matchedText: original.substring(idx, idx + needle.length),
    );
  }

  static void _addKeywordHighlight({
    required String original,
    required String normalized,
    required List<String> needles,
    required String warningKey,
    required List<ClauseHighlight> highlights,
  }) {
    for (final needle in needles) {
      if (!_matchesKeyword(normalized, needle) &&
          !normalized.contains(needle.toLowerCase()) &&
          !original.contains(needle)) {
        continue;
      }
      final h = _findHighlight(original, needle, warningKey);
      if (h != null) {
        // Avoid duplicate overlapping spans for same key+range
        final exists = highlights.any(
          (e) => e.warningKey == warningKey && e.start == h.start && e.end == h.end,
        );
        if (!exists) highlights.add(h);
        return; // one visible phrase per keyword set is enough
      }
    }
  }

  static void _addRegexHighlight({
    required String original,
    required String normalized,
    required RegExp pattern,
    required String warningKey,
    required List<ClauseHighlight> highlights,
  }) {
    final match = pattern.firstMatch(normalized);
    if (match == null) return;
    // Map normalized index to original (same length if only case differs)
    final start = match.start;
    final end = match.end;
    if (start < 0 || end > original.length) return;
    highlights.add(
      ClauseHighlight(
        start: start,
        end: end,
        warningKey: warningKey,
        matchedText: original.substring(start, end),
      ),
    );
  }

  static DocumentAnalysis analyze(String text) {
    final trimmed = text.trim();
    final normalized = trimmed.toLowerCase();
    // Keep original casing for display highlights — use trimmed as base
    final original = trimmed;

    if (trimmed.length < 10 || trimmed.split(RegExp(r'\s+')).length < 2) {
      return DocumentAnalysis(
        category: DocumentCategory.unclear,
        severity: DocumentSeverity.unknown,
        warningKeys: ['alert_unclear_image'],
        rawText: text,
        analyzedAt: DateTime.now(),
        confidenceScore: 0.0,
      );
    }

    final legalScore = _countMatches(normalized, legalMarkers);
    final loanScore = _countMatches(normalized, loanKeywords);
    final deedScore = _countMatches(normalized, deedKeywords);
    final jobScore = _countMatches(normalized, jobKeywords);
    final medicalScore = _countMatches(normalized, medicalKeywords);
    final totalScore =
        legalScore + loanScore + deedScore + jobScore + medicalScore;

    if (totalScore == 0 ||
        (loanScore == 0 &&
            deedScore == 0 &&
            jobScore == 0 &&
            medicalScore == 0 &&
            legalScore < 2)) {
      return DocumentAnalysis(
        category: DocumentCategory.unrecognized,
        severity: DocumentSeverity.unknown,
        warningKeys: ['info_non_legal_document'],
        rawText: text,
        analyzedAt: DateTime.now(),
        confidenceScore: 0.1,
      );
    }

    DocumentCategory category = DocumentCategory.loan;
    int highestScore = loanScore;

    if (deedScore > highestScore) {
      category = DocumentCategory.deed;
      highestScore = deedScore;
    }
    if (jobScore > highestScore) {
      category = DocumentCategory.job;
      highestScore = jobScore;
    }
    if (medicalScore > highestScore) {
      category = DocumentCategory.medical;
      highestScore = medicalScore;
    }

    if (highestScore < 1 && legalScore < 2) {
      return DocumentAnalysis(
        category: DocumentCategory.unrecognized,
        severity: DocumentSeverity.unknown,
        warningKeys: ['info_non_legal_document'],
        rawText: text,
        analyzedAt: DateTime.now(),
        confidenceScore: 0.2,
      );
    }

    final List<String> warnings = [];
    final List<ClauseHighlight> highlights = [];
    DocumentSeverity severity = DocumentSeverity.safe;

    // --- LOAN ---
    if (category == DocumentCategory.loan) {
      final interestRegex = RegExp(
        r'(\d+)%\s*(?:per annum|annual|interest|yearly|interest rate|ब्याज|प्रति वर्ष)',
        caseSensitive: false,
      );
      final match = interestRegex.firstMatch(normalized);
      int interestRate = 0;

      if (match != null && match.group(1) != null) {
        interestRate = int.tryParse(match.group(1)!) ?? 0;
        _addRegexHighlight(
          original: original,
          normalized: normalized,
          pattern: interestRegex,
          warningKey: 'alert_high_interest',
          highlights: highlights,
        );
      } else {
        final monthlyRegex = RegExp(
          r'(\d+)%\s*(?:per month|monthly|प्रति माह)',
          caseSensitive: false,
        );
        final monthlyMatch = monthlyRegex.firstMatch(normalized);
        if (monthlyMatch != null && monthlyMatch.group(1) != null) {
          interestRate = (int.tryParse(monthlyMatch.group(1)!) ?? 0) * 12;
          _addRegexHighlight(
            original: original,
            normalized: normalized,
            pattern: monthlyRegex,
            warningKey: 'alert_high_interest',
            highlights: highlights,
          );
        }
      }

      if (interestRate >= 24 ||
          normalized.contains('30%') ||
          normalized.contains('36%') ||
          normalized.contains('40%') ||
          _matchesKeyword(normalized, 'compound interest') ||
          normalized.contains('चक्रवृद्धि')) {
        warnings.add('alert_high_interest');
        severity = DocumentSeverity.danger;
        _addKeywordHighlight(
          original: original,
          normalized: normalized,
          needles: [
            'compound interest',
            'चक्रवृद्धि',
            '30%',
            '36%',
            '40%',
            'interest rate',
            'ब्याज',
          ],
          warningKey: 'alert_high_interest',
          highlights: highlights,
        );
      }

      if (_matchesKeyword(normalized, 'seize') ||
          _matchesKeyword(normalized, 'collateral') ||
          _matchesKeyword(normalized, 'forfeit') ||
          _matchesKeyword(normalized, 'mortgage') ||
          normalized.contains('guarantee land') ||
          normalized.contains('गिरवी') ||
          normalized.contains('जब्त') ||
          normalized.contains('அடமானம்')) {
        warnings.add('alert_collateral');
        severity = DocumentSeverity.danger;
        _addKeywordHighlight(
          original: original,
          normalized: normalized,
          needles: [
            'seize',
            'collateral',
            'forfeit',
            'mortgage',
            'guarantee land',
            'गिरवी',
            'जब्त',
            'அடமானம்',
          ],
          warningKey: 'alert_collateral',
          highlights: highlights,
        );
      }

      if (normalized.contains('processing fee') ||
          normalized.contains('admin fee') ||
          normalized.contains('hidden cost') ||
          _matchesKeyword(normalized, 'commission') ||
          normalized.contains('कमीशन')) {
        warnings.add('alert_hidden_fee');
        if (severity != DocumentSeverity.danger) {
          severity = DocumentSeverity.warning;
        }
        _addKeywordHighlight(
          original: original,
          normalized: normalized,
          needles: [
            'processing fee',
            'admin fee',
            'hidden cost',
            'commission',
            'कमीशन',
          ],
          warningKey: 'alert_hidden_fee',
          highlights: highlights,
        );
      }
    }

    // --- DEED ---
    if (category == DocumentCategory.deed) {
      if (normalized.contains('transfer all rights') ||
          _matchesKeyword(normalized, 'irrevocable') ||
          _matchesKeyword(normalized, 'relinquish') ||
          normalized.contains('अधिकार हस्तांतरण')) {
        warnings.add('alert_collateral');
        severity = DocumentSeverity.danger;
        _addKeywordHighlight(
          original: original,
          normalized: normalized,
          needles: [
            'transfer all rights',
            'irrevocable',
            'relinquish',
            'अधिकार हस्तांतरण',
          ],
          warningKey: 'alert_collateral',
          highlights: highlights,
        );
      }
      if (normalized.contains('without consent') ||
          normalized.contains('spouse signature') ||
          normalized.contains('बिना सहमति')) {
        warnings.add('alert_collateral');
        if (severity != DocumentSeverity.danger) {
          severity = DocumentSeverity.warning;
        }
        _addKeywordHighlight(
          original: original,
          normalized: normalized,
          needles: [
            'without consent',
            'spouse signature',
            'बिना सहमति',
          ],
          warningKey: 'alert_collateral',
          highlights: highlights,
        );
      }
    }

    // --- JOB ---
    if (category == DocumentCategory.job) {
      if (normalized.contains('overtime without pay') ||
          normalized.contains('no overtime') ||
          normalized.contains('additional hours') ||
          normalized.contains('बिना अतिरिक्त भुगतान')) {
        warnings.add('alert_unpaid_labor');
        severity = DocumentSeverity.danger;
        _addKeywordHighlight(
          original: original,
          normalized: normalized,
          needles: [
            'overtime without pay',
            'no overtime',
            'additional hours',
            'बिना अतिरिक्त भुगतान',
          ],
          warningKey: 'alert_unpaid_labor',
          highlights: highlights,
        );
      }
      if (normalized.contains('cannot resign') ||
          normalized.contains('bond period') ||
          normalized.contains('penalty fee') ||
          normalized.contains('notice period 6 months') ||
          normalized.contains('जुर्माना')) {
        warnings.add('alert_no_exit');
        if (severity != DocumentSeverity.danger) {
          severity = DocumentSeverity.warning;
        }
        _addKeywordHighlight(
          original: original,
          normalized: normalized,
          needles: [
            'cannot resign',
            'bond period',
            'penalty fee',
            'notice period 6 months',
            'जुर्माना',
          ],
          warningKey: 'alert_no_exit',
          highlights: highlights,
        );
      }
    }

    // --- MEDICAL ---
    if (category == DocumentCategory.medical) {
      if (normalized.contains('not responsible') ||
          normalized.contains('waive liability') ||
          normalized.contains('at own risk') ||
          normalized.contains('no claims') ||
          normalized.contains('जिम्मेदार नहीं')) {
        warnings.add('alert_medical_liability');
        severity = DocumentSeverity.warning;
        _addKeywordHighlight(
          original: original,
          normalized: normalized,
          needles: [
            'not responsible',
            'waive liability',
            'at own risk',
            'no claims',
            'जिम्मेदार नहीं',
          ],
          warningKey: 'alert_medical_liability',
          highlights: highlights,
        );
      }
    }

    // Sort highlights by position for rendering
    highlights.sort((a, b) => a.start.compareTo(b.start));

    return DocumentAnalysis(
      category: category,
      severity: severity,
      warningKeys: warnings,
      rawText: original,
      analyzedAt: DateTime.now(),
      confidenceScore: (highestScore / 5.0).clamp(0.4, 1.0),
      highlights: highlights,
    );
  }
}
