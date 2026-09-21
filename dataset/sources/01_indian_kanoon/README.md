# Source 1 — Indian Kanoon

**Website**: https://indiankanoon.org  
**Type**: Court judgments, consumer forum orders, moneylending dispute records  
**Coverage**: 1.5M+ documents across Supreme Court, High Courts, District Courts, Consumer Forums  
**Language**: English, Hindi, and regional languages  

---

## 📌 Why This Dataset Matters for VaakSetu

Indian Kanoon contains **real fraud cases** — rural borrowers cheated by moneylenders, land deed forgeries, bonded labour disputes, and hospital negligence cases. These are ground-truth examples of exactly what VaakSetu is designed to detect.

### Key search queries for relevant data:
- `"moneylender" AND "interest rate" AND "land seizure"`
- `"blank cheque" AND "loan" AND "coercion"`
- `"sale deed" AND "forged" AND "thumb impression"`
- `"bonded labour" AND "penalty" AND "resignation"`
- `"stamp paper" AND "blank" AND "fraud"`

---

## 🔗 How to Access

### Option A: Public Search API (Recommended)
Indian Kanoon provides a free read API:
```
GET https://api.indiankanoon.org/search/?formInput=moneylender+interest+rate+land+seizure&pagenum=1
Authorization: Token YOUR_API_KEY
```
**Register for free at**: https://indiankanoon.org/api/

### Option B: Manual Case Search
1. Go to https://indiankanoon.org
2. Search: `moneylender fraud land seizure interest rate`
3. Filter by: Consumer Forums, District Courts
4. Download cases as PDF or copy text

---

## 📄 Data Format

Collected cases should be structured as:
```json
{
  "case_id": "IK_2019_WB_12345",
  "court": "Consumer Forum, West Bengal",
  "year": 2019,
  "category": "loan_fraud",
  "risk_level": "danger",
  "text_excerpt": "The complainant states that the opposite party moneylender charged 48% compound interest per annum on a Rs. 40,000 loan, and forcibly took thumb impression on blank stamp paper to transfer agricultural land...",
  "red_flags_found": ["predatory_interest", "blank_stamp_paper", "coerced_signature", "land_seizure"],
  "source_url": "https://indiankanoon.org/doc/12345/",
  "language": "en"
}
```

---

## 📁 Files in This Folder

| File | Description |
|------|-------------|
| `README.md` | This file |
| `sample_cases.json` | 5 curated real case excerpts in VaakSetu format |
| `scraper_guide.md` | Step-by-step guide to fetch cases using the API |
| `query_templates.txt` | Optimised search query templates |
