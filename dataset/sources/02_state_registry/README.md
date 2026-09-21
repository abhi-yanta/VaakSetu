# Source 2 — State Revenue & Registry Portals

**Portals**: Bhulekh (UP), e-Dharani (Telangana), AnyRoR (Gujarat), Bhunaksha (MP), Jamabandi (Haryana)  
**Type**: Official Indian land deed formats — Bainama (Sale Deed), Khasra-Khatauni records, Vikray Patra  
**Coverage**: All major Indian states  
**Language**: Hindi, Telugu, Gujarati, and respective state language  

---

## 📌 Why This Dataset Matters for VaakSetu

These portals contain **authentic government-registered land deed templates**. By learning from these, VaakSetu can:
1. Identify whether a land deed matches the official government format.
2. Detect missing mandatory fields (e.g. no co-owner signature, no stamp duty receipt).
3. Flag suspicious deeds with under-declared market value or missing Khasra numbers.

---

## 🔗 How to Access

### State-wise Portal Links

| State | Portal | Document Type |
|-------|--------|---------------|
| Uttar Pradesh | https://bhulekh.up.gov.in | Khasra, Khatauni, Bainama |
| Telangana | https://dharani.telangana.gov.in | e-Dharani Deed |
| Gujarat | https://anyror.gujarat.gov.in | 7/12, Bainama, Hak Patra |
| Madhya Pradesh | https://mpbhulekh.gov.in | Khasra, Bhu-Adhikar Pustika |
| Rajasthan | https://apnakhata.rajasthan.gov.in | Jamabandi, Nakal |
| West Bengal | https://banglarbhumi.gov.in | RoR (Record of Rights), Bainama |
| Maharashtra | https://mahabhulekh.maharashtra.gov.in | Satbara Utara |

### Download Model Deed Formats
1. Visit your state's registration department website.
2. Look for "Model Deeds" or "Specimen Documents" section.
3. Download the PDF template of Sale Deed (Vikray Patra).

---

## 📄 Data Format

Land record entries should be structured as:
```json
{
  "record_id": "WB_MSD_2016_C579202",
  "state": "West Bengal",
  "district": "Murshidabad",
  "tehsil": "Suti",
  "document_type": "sale_deed",
  "stamp_paper_value": 5000,
  "registration_number": "C 579202",
  "date": "2016-05-17",
  "area_transferred": "11.347 Decimals",
  "area_sqm": 459.369,
  "consideration_amount": 819112,
  "mouza": "Dafahat",
  "jl_number": "56",
  "parties": {
    "seller": "REDACTED",
    "purchaser": "A.M. Teachers Training Institute"
  },
  "is_legal_document": true,
  "risk_level": "safe",
  "missing_fields": [],
  "red_flags": []
}
```

---

## 📁 Files in This Folder

| File | Description |
|------|-------------|
| `README.md` | This file |
| `sample_sale_deed.json` | Sample West Bengal stamp paper Sale Deed (like the one scanned by user) |
| `sample_khasra_record.json` | Sample Khasra-Khatauni land record |
| `deed_field_checklist.json` | Mandatory fields that must be present in a valid registered deed |
