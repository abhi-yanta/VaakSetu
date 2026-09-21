# Synthetic Dataset — VaakSetu Auto-Generated Benchmark

This folder contains the **auto-generated benchmark dataset** for VaakSetu.
It is used to unit-test the rule engine and measure classification accuracy.

---

## 📊 Dataset Statistics

| Split | Count | Purpose |
|-------|-------|---------|
| Predatory Loans (Danger) | 20 | High-interest, land seizure, advance fees |
| Safe Bank Loans | 15 | RBI-compliant, no collateral |
| Land Sale Deeds | 15 | Registered deeds, stamp papers |
| Exploitative Labor Contracts | 15 | Bonded labour, unpaid overtime |
| Medical Consent Waivers | 15 | Negligence release forms |
| Hindi Devanagari Legal Docs | 2 | Vernacular legal documents |
| **Non-Legal Distractors** | **6** | Notebooks, receipts, homework, recipes |
| **Total** | **88** | |

---

## 📁 Files

| File | Description |
|------|-------------|
| `vaaksetu_dataset.json` | Full annotated dataset (88 records) |
| `vaaksetu_dataset.csv` | Same dataset in CSV format for spreadsheet tools |
| `generate_dataset.dart` | Dart script that generates the dataset |
| `evaluate_dataset.dart` | Dart script that benchmarks rule engine against dataset |

---

## 🚀 How to Run

From the `mobile/` directory:

```bash
# Regenerate dataset (adds more samples, updates existing ones)
dart run tool/generate_dataset.dart

# Benchmark the rule engine against this dataset
dart run tool/evaluate_dataset.dart
```

**Latest benchmark results:**
```
Category Accuracy:          100.0% (88/88)
Legal Document Precision:   100.0%  ← 0 false positives
Legal Document Recall:      100.0%  ← 0 missed legal docs
F1 Score:                   100.0%
```

---

## 📄 Record Schema

```json
{
  "id": "loan_danger_1",
  "category": "loan | deed | job | medical | unrecognized | unclear",
  "is_legal_document": true,
  "risk_level": "safe | warning | danger | unknown",
  "language": "en | hi | ta | ...",
  "text": "...",
  "expected_warnings": ["alert_high_interest", "alert_collateral", ...]
}
```

---

> **Note**: This is a *synthetic* dataset hand-crafted for benchmarking.
> For real-world training, use the external sources in `../sources/`.
