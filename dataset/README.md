# 📂 VaakSetu Dataset Hub

This folder centralises **all training data, benchmark corpora, and reference datasets** used for VaakSetu — the AI-powered legal document protection system for rural India.

---

## 🗂️ Folder Structure

```
dataset/
├── README.md                          ← You are here
├── sources/
│   ├── 01_indian_kanoon/              ← Court judgments, fraud contracts
│   ├── 02_state_registry/             ← Land deed templates (Bainama, Khasra-Khatauni)
│   ├── 03_rbi_fair_practices/         ← RBI FPC guidelines & illegal moneylending terms
│   ├── 04_cuad/                       ← 510+ legal agreements from Atticus Project
│   ├── 05_claudette/                  ← Unfair consumer contract clauses
│   └── 06_ai4bharat_indic_ocr/        ← 22 Indian language printed/handwritten documents
└── synthetic/
    ├── vaaksetu_dataset.json          ← 88 labelled synthetic samples (auto-generated)
    ├── vaaksetu_dataset.csv           ← Same dataset in CSV format
    ├── generate_dataset.dart          ← Generator script (Dart)
    └── evaluate_dataset.dart          ← Rule engine benchmarking script
```

---

## 📊 Dataset Sources at a Glance

| # | Source | Type of Data | Size | Access |
|---|--------|-------------|------|--------|
| 1 | **Indian Kanoon** | Court judgments, moneylending fraud, forged deeds | 1.5M+ docs | Public API / Scraper |
| 2 | **State Revenue & Registry Portals** (Bhulekh, e-Dharani, AnyRoR) | Bainama, Khasra-Khatauni, Sale Deed templates | Variable | Official portal download |
| 3 | **RBI Fair Practices Code (FPC)** | Guidelines on illegal moneylending / compound interest | 50+ circulars | RBI.org.in (public) |
| 4 | **CUAD (Atticus Project)** | 510+ legal agreements, 13,000+ clause annotations | 513 contracts | HuggingFace (open) |
| 5 | **CLAUDETTE Dataset** | Consumer contracts annotated for unfair & predatory terms | 82+ contracts | Academic paper data |
| 6 | **AI4Bharat IndicOCR** | Indian language printed and handwritten documents | 22 languages | Open download |
| 7 | **VaakSetu Synthetic** | Hand-crafted labelled samples across 5 legal categories | 88 records | Generated locally |

---

## 🎯 Dataset Purpose & Usage

| Dataset | Used For |
|---------|----------|
| Indian Kanoon | Training NER on real Indian legal disputes — loan fraud, deed forgery, bonded labour |
| State Registry | Ground truth for genuine deed formats vs. forged/coerced land transfer patterns |
| RBI FPC | Defining "predatory" interest rate thresholds — basis for the 24% APR danger cutoff |
| CUAD | Clause-level classification training — maps to VaakSetu's risk categories |
| CLAUDETTE | Unfair clause detection — consumer protection focus, similar to VaakSetu's warning system |
| AI4Bharat IndicOCR | Fine-tuning OCR noise resilience for rural/handwritten documents in 12 supported languages |
| VaakSetu Synthetic | Unit-testing the rule engine; baseline before collecting real-world data |

---

## 🚀 Quick Start

### Generate / refresh the synthetic dataset
```bash
cd ../mobile
dart run tool/generate_dataset.dart
```

### Evaluate rule engine accuracy against dataset
```bash
cd ../mobile
dart run tool/evaluate_dataset.dart
```

### Download CUAD via HuggingFace (requires Python + datasets library)
```bash
cd sources/04_cuad
pip install datasets
python download_cuad.py
```
