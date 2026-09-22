# Source 6 — AI4Bharat IndicOCR & All Datasets

**Project**: AI4Bharat (IIT Madras)  
**Website**: https://ai4bharat.iitm.ac.in  
**GitHub**: https://github.com/AI4Bharat  
**HuggingFace**: https://huggingface.co/ai4bharat  

---

## 📦 Complete AI4Bharat Dataset Catalog (VaakSetu Relevant)

### 🗣️ Speech (ASR / TTS)

| Dataset | Description | Size | VaakSetu Use |
|---------|-------------|------|-------------|
| **Shrutilipi** | Labeled ASR corpus from All India Radio | 6,400+ hours, 12 languages | Train offline speech recognition for document dictation |
| **IndicVoices** | Large-scale multilingual speech (diverse speakers, rural accents) | Thousands of hours | Improve rural accent recognition in voice commands |
| **Kathbath** | Robust ASR benchmark | 1,684 hrs, 12 languages | Benchmark VaakSetu voice input accuracy |
| **Rasa** | Expressive multilingual TTS dataset | 12 languages | **Train AI4Bharat TTS** used in VaakSetu |
| **BhasaAnuvaad** | Speech translation dataset | 44,400 hrs, 13 languages | Cross-language document explanation |

### 📝 Text / NLP

| Dataset | Description | Size | VaakSetu Use |
|---------|-------------|------|-------------|
| **Samanantar** | English↔Indic parallel corpus | 49.7M sentence pairs, 11 languages | Legal clause translation between languages |
| **IndicNLP Corpora** | Monolingual text for 12 Indian languages | Billions of tokens | Language model pre-training |
| **Sangraha** | Curated high-quality multilingual text | Large | LLM fine-tuning for legal understanding |
| **Aksharantar** | Roman ↔ Native script transliteration | 26M pairs | Handle mixed-script OCR output |
| **Naamapadam** | Named Entity Recognition dataset | 400K sentences, 11 languages | Identify party names, land survey numbers in contracts |
| **IndicGLUE** | NLU benchmark | 11 languages | Evaluate legal text classification models |

### 👁️ OCR / Vision

| Dataset | Description | Size | VaakSetu Use |
|---------|-------------|------|-------------|
| **IndicOCR** | Printed text across 13 Indic scripts | Large | Fine-tune OCR for stamp papers, printed deeds |

---

## 🔗 Download Links

| Dataset | Download |
|---------|----------|
| Shrutilipi | https://huggingface.co/datasets/ai4bharat/shrutilipi |
| IndicVoices | https://huggingface.co/datasets/ai4bharat/indicvoices |
| Kathbath | https://huggingface.co/datasets/ai4bharat/kathbath |
| Rasa (TTS) | https://huggingface.co/datasets/ai4bharat/rasa |
| Samanantar | https://huggingface.co/datasets/ai4bharat/samanantar |
| Aksharantar | https://huggingface.co/datasets/ai4bharat/Aksharantar |
| Naamapadam | https://huggingface.co/datasets/ai4bharat/naamapadam |

---

## 🎙️ AI4Bharat TTS Models (Used in VaakSetu)

VaakSetu now uses **Bhashini API** (Government of India) which hosts AI4Bharat's TTS models:

| Model | Quality | Languages | Access |
|-------|---------|-----------|--------|
| **Indic Parler-TTS** | Expressive, natural | 23+ languages | HuggingFace + Bhashini |
| **IndicF5** | Near-human quality | 22 languages | HuggingFace |
| **Indic-TTS (FastPitch)** | Lightweight, offline | 13 languages | GitHub |

See `../../mobile/lib/data/services/tts_service.dart` for the implementation.

---

## 📁 Files in This Folder

| File | Description |
|------|-------------|
| `README.md` | This file |
| `supported_languages.json` | 12 VaakSetu languages → AI4Bharat script codes |
| `ai4bharat_datasets_catalog.json` | Full machine-readable catalog of all relevant datasets |
| `download_datasets.py` | Script to download key datasets from HuggingFace |
