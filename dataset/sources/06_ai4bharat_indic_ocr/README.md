# Source 6 — AI4Bharat IndicOCR

**Project**: AI4Bharat (IIT Madras)  
**Website**: https://ai4bharat.iitm.ac.in  
**GitHub**: https://github.com/AI4Bharat  
**HuggingFace**: https://huggingface.co/ai4bharat  
**Type**: Indian language printed and handwritten document datasets  
**Coverage**: 22 scheduled Indian languages  
**Language**: Hindi, Tamil, Telugu, Bengali, Marathi, Gujarati, Kannada, Malayalam, Odia, Punjabi, Assamese, Urdu + others  

---

## 📌 Why This Dataset Matters for VaakSetu

VaakSetu's OCR layer (Google ML Kit) struggles with:
1. **Handwritten text** on rural loan agreements (thumb impressions + cursive Devanagari)
2. **Mixed-script** stamp papers (Bengali + English as seen in the West Bengal deed)
3. **Low-quality scans** from cheap Android cameras in poor lighting

AI4Bharat's datasets let us **fine-tune OCR models** specifically for these challenges.

### Key Datasets from AI4Bharat

| Dataset | Description | Use Case |
|---------|-------------|----------|
| **IndicOCR** | Printed text in 13 Indic scripts | Improve stamp paper + deed OCR |
| **Shrutilipi** | 1600+ hours of Indian language speech | TTS voice quality improvement |
| **Aksharantar** | 26M transliteration pairs | Cross-script keyword matching |
| **IndicNLP** | NLP corpora for 22 Indian languages | Legal text classification |
| **IndicTrans2** | Translation between 22 languages | Multi-language explanation |

---

## 📥 How to Access

### Method 1: HuggingFace
```bash
pip install datasets
python -c "from datasets import load_dataset; ds = load_dataset('ai4bharat/indicocr')"
```

### Method 2: AI4Bharat Website
1. Visit https://ai4bharat.iitm.ac.in/datasets
2. Register (free academic access)
3. Download IndicOCR dataset

### Method 3: GitHub
```bash
git clone https://github.com/AI4Bharat/IndicOCR
```

---

## 🔗 Direct Dataset Links

| Resource | URL |
|----------|-----|
| IndicOCR Paper | https://arxiv.org/abs/2212.02234 |
| IndicNLP Suite | https://indicnlp.ai4bharat.org/ |
| Aksharantar | https://huggingface.co/datasets/ai4bharat/Aksharantar |
| IndicTrans2 | https://github.com/AI4Bharat/IndicTrans2 |

---

## 📁 Files in This Folder

| File | Description |
|------|-------------|
| `README.md` | This file |
| `supported_languages.json` | 12 VaakSetu languages mapped to AI4Bharat script codes |
| `download_indicocr.py` | Script to download relevant OCR training samples |
