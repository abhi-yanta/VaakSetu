# Source 4 — CUAD (Contract Understanding Atticus Dataset)

**Project**: The Atticus Project  
**Website**: https://www.atticusprojectai.org/cuad  
**HuggingFace**: https://huggingface.co/datasets/cuad  
**Type**: 510+ legal agreements with 13,000+ expert annotations across 41 clause categories  
**Language**: English  
**License**: CC BY 4.0 (Open)  

---

## 📌 Why This Dataset Matters for VaakSetu

CUAD is the **gold standard** for legal clause extraction. It maps 41 contract clause types to risk categories, many of which directly correspond to VaakSetu's warning system:

| CUAD Clause | VaakSetu Mapping | Risk Level |
|-------------|-----------------|-----------|
| Termination for Convenience | alert_no_exit | warning |
| Liquidated Damages | alert_no_exit | danger |
| Non-Disparagement | unrecognized (not applicable) | — |
| Uncapped Liability | alert_collateral | danger |
| Most Favored Nation | — | — |
| IP Ownership Assignment | — | — |
| Indemnification | alert_medical_liability | warning |
| Limitation of Liability | alert_medical_liability | warning |

---

## 📥 How to Download

### Method 1: HuggingFace CLI (Recommended)
```bash
pip install datasets
python download_cuad.py
```

### Method 2: Direct Download
Visit https://huggingface.co/datasets/cuad/tree/main and download:
- `CUADv1.json` — Full dataset with all annotations
- `train/` — Training split (430 contracts)
- `test/` — Test split (102 contracts)

---

## 📁 Files in This Folder

| File | Description |
|------|-------------|
| `README.md` | This file |
| `download_cuad.py` | Python script to download CUAD from HuggingFace |
| `cuad_to_vaaksetu_mapping.json` | Maps CUAD's 41 clause categories to VaakSetu categories |
| `sample_cuad_entry.json` | Sample CUAD entry showing annotation format |
