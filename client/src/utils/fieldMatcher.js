/**
 * Fuzzy Field-Label Matcher
 * Uses Levenshtein distance and token-overlap fuzzy matching to identify
 * form field labels from noisy OCR bounding box line data.
 */

import { FIELD_DEFINITIONS } from './formFieldDictionary';

/**
 * Compute Levenshtein distance between two strings
 */
export function levenshteinDistance(a, b) {
  if (a.length === 0) return b.length;
  if (b.length === 0) return a.length;

  const matrix = [];
  for (let i = 0; i <= b.length; i++) {
    matrix[i] = [i];
  }
  for (let j = 0; j <= a.length; j++) {
    matrix[0][j] = j;
  }

  for (let i = 1; i <= b.length; i++) {
    for (let j = 1; j <= a.length; j++) {
      if (b.charAt(i - 1) === a.charAt(j - 1)) {
        matrix[i][j] = matrix[i - 1][j - 1];
      } else {
        matrix[i][j] = Math.min(
          matrix[i - 1][j - 1] + 1, // substitution
          matrix[i][j - 1] + 1,     // insertion
          matrix[i - 1][j] + 1      // deletion
        );
      }
    }
  }

  return matrix[b.length][a.length];
}

/**
 * Calculate normalized similarity ratio between 0.0 and 1.0
 */
export function stringSimilarity(str1, str2) {
  const s1 = (str1 || '').trim().toLowerCase();
  const s2 = (str2 || '').trim().toLowerCase();
  if (s1 === s2) return 1.0;
  if (!s1 || !s2) return 0.0;

  const maxLen = Math.max(s1.length, s2.length);
  if (maxLen === 0) return 1.0;

  const distance = levenshteinDistance(s1, s2);
  return 1 - distance / maxLen;
}

/**
 * Clean and normalize text line for fuzzy matching
 */
function cleanLineText(text) {
  return (text || '')
    .toLowerCase()
    .replace(/[:\-_\.\*\|\/\\#]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

/**
 * Match a single line/phrase against all field keywords
 */
export function matchFieldInText(rawText, userLang = 'hi') {
  const clean = cleanLineText(rawText);
  if (!clean || clean.length < 2) return null;

  let bestMatch = null;
  let highestScore = 0;

  for (const [fieldKey, fieldDef] of Object.entries(FIELD_DEFINITIONS)) {
    for (const kw of fieldDef.keywords) {
      const cleanKw = cleanLineText(kw);
      if (!cleanKw) continue;

      let score = 0;

      // 1. Direct exact or substring containment
      if (clean === cleanKw) {
        score = 1.0;
      } else if (clean.includes(cleanKw) || cleanKw.includes(clean)) {
        score = Math.min(cleanKw.length, clean.length) / Math.max(cleanKw.length, clean.length);
        score = Math.max(score, 0.88);
      } else {
        // 2. Token overlap similarity
        const lineTokens = clean.split(' ');
        const kwTokens = cleanKw.split(' ');
        
        let tokenMatchCount = 0;
        for (const kt of kwTokens) {
          if (lineTokens.some(lt => stringSimilarity(lt, kt) >= 0.80)) {
            tokenMatchCount++;
          }
        }

        if (tokenMatchCount > 0 && tokenMatchCount === kwTokens.length) {
          score = 0.85;
        } else {
          // 3. Normalized Levenshtein similarity
          const sim = stringSimilarity(clean, cleanKw);
          if (sim >= 0.75) {
            score = sim * 0.9;
          }
        }
      }

      if (score > highestScore && score >= 0.70) {
        highestScore = score;
        bestMatch = {
          fieldKey,
          canonicalLabel: fieldDef.defaultLabel,
          translatedLabel: fieldDef.labels[userLang] || fieldDef.labels.hi || fieldDef.defaultLabel,
          matchedKeyword: kw,
          confidence: score
        };
      }
    }
  }

  return bestMatch;
}

/**
 * Extract form fields from Tesseract OCR output
 * @param {Object} ocrResult - Tesseract recognition output (ret.data)
 * @param {string} userLang - User language code (e.g. 'hi', 'ta')
 * @returns {Array} - Array of detected field objects with bounding boxes
 */
export function extractFormFieldsFromOCR(ocrResult, userLang = 'hi') {
  if (!ocrResult) return [];

  const detectedFields = [];
  const lines = ocrResult.lines || [];

  // If no lines array provided, attempt word-level or text parsing
  if (lines.length === 0 && ocrResult.text) {
    const rawLines = ocrResult.text.split('\n');
    rawLines.forEach((lineText, idx) => {
      const match = matchFieldInText(lineText, userLang);
      if (match) {
        detectedFields.push({
          id: `field_${match.fieldKey}_${idx}`,
          fieldKey: match.fieldKey,
          label: match.canonicalLabel,
          translatedLabel: match.translatedLabel,
          matchedText: lineText.trim(),
          matchConfidence: match.confidence,
          bbox: {
            x0: 50,
            y0: 80 + idx * 60,
            x1: 250,
            y1: 110 + idx * 60,
            width: 200,
            height: 30
          }
        });
      }
    });
    return deduplicateFields(detectedFields);
  }

  // Iterate over actual OCR lines with bounding boxes
  lines.forEach((line, index) => {
    const text = (line.text || '').trim();
    if (!text) return;

    const match = matchFieldInText(text, userLang);
    if (match) {
      const bbox = line.bbox || {
        x0: line.x0 || 50,
        y0: line.y0 || 100 + index * 50,
        x1: line.x1 || 300,
        y1: line.y1 || 130 + index * 50
      };

      const width = Math.max((bbox.x1 - bbox.x0), 20);
      const height = Math.max((bbox.y1 - bbox.y0), 16);

      detectedFields.push({
        id: `field_${match.fieldKey}_${index}`,
        fieldKey: match.fieldKey,
        label: match.canonicalLabel,
        translatedLabel: match.translatedLabel,
        matchedText: text,
        matchConfidence: match.confidence,
        bbox: {
          x0: bbox.x0,
          y0: bbox.y0,
          x1: bbox.x1,
          y1: bbox.y1,
          width,
          height
        }
      });
    }
  });

  return deduplicateFields(detectedFields);
}

/**
 * Deduplicate multiple detections of the same field if close to each other
 */
function deduplicateFields(fields) {
  const unique = [];
  const seenKeys = new Map();

  for (const f of fields) {
    if (!seenKeys.has(f.fieldKey)) {
      seenKeys.set(f.fieldKey, f);
      unique.push(f);
    } else {
      const existing = seenKeys.get(f.fieldKey);
      // If higher confidence or better box, replace
      if (f.matchConfidence > existing.matchConfidence) {
        const idx = unique.indexOf(existing);
        if (idx !== -1) unique[idx] = f;
        seenKeys.set(f.fieldKey, f);
      }
    }
  }

  return unique;
}
