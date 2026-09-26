# VaakSetu Form Field Guide Dataset

Export of the Form Field Guide dictionary and bilingual form demo presets from the VaakSetu Flutter app.

| Path | Role |
|------|------|
| `dataset/form_guide/` (repo root) | Documentation + ML / offline training use |
| `mobile/assets/dataset/form_guide/` | Same JSON mirrored as Flutter assets |

**Runtime note:** The app still loads field definitions from Dart (`FormFieldDictionary` in `mobile/lib/domain/models/form_field_model.dart`) and form presets from `PresetService` (`mobile/lib/data/services/preset_service.dart`). These JSON files are an exact export for ML, tooling, and documentation—not the live runtime source of truth (unless you later wire asset loading).

Regenerate after editing Dart dictionaries:

```bash
cd mobile
flutter test tool/export_form_guide_dataset.dart
```

Then copy `schema.json` / this `README.md` into `mobile/assets/dataset/form_guide/` if you changed them (the exporter only refreshes `fields.json` and `form_presets.json`).

---

## Stats (current export)

| Metric | Value |
|--------|------:|
| Field definitions | **22** |
| Form presets (`isForm: true`) | **5** |
| Languages (labels + spokenHelp) | **13** — `as`, `bn`, `en`, `gu`, `hi`, `kn`, `ml`, `mr`, `or`, `pa`, `ta`, `te`, `ur` |
| Keyword phrases (all fields) | **629** multilingual OCR match strings |

### Field keys

`name`, `dob`, `gender`, `phone`, `address`, `id_number`, `signature`, `date`, `father_name`, `mother_name`, `age`, `email`, `pincode`, `village`, `district`, `bank_account`, `ifsc`, `income`, `category`, `occupation`, `education`, `marital_status`

### Form presets

| id | Description |
|----|-------------|
| `kisan_welfare_form` | Government welfare / beneficiary bilingual form |
| `scholarship_form` | Student scholarship application |
| `ration_card_form` | PDS ration card application |
| `bank_kyc_form` | Bank KYC / account opening |
| `job_application_form` | Employment application |

---

## Files

| File | Contents |
|------|----------|
| `fields.json` | All `FormFieldDefinition`s: `key`, `defaultLabel`, `keywords`, `labels`, `spokenHelp` |
| `form_presets.json` | All `PresetService` entries with `isForm: true`: `id`, `title`, `previewDescription`, `fullText`, `isForm` |
| `schema.json` | JSON Schema for the two file shapes |
| `README.md` | This document |

---

## How FormFieldEngine uses this data

VaakSetu Form Guide is **not** a custom neural model today. Pipeline:

1. **OCR** — Google **ML Kit** text recognition on camera / gallery images (or demo preset `fullText`).
2. **Form detection** — `FormFieldEngine.looksLikeForm()` scores title/section hints (e.g. “application form”, आवेदन पत्र) and colon-heavy layouts.
3. **Dictionary matching** — OCR lines are matched against `FormFieldDictionary.keywords` using similarity / token overlap / Levenshtein-style scoring (see `form_field_engine.dart`).
4. **Guidance** — Matched `fieldKey` → localized `labels` + `spokenHelp` + blank-box position heuristics (`below` / `right` / `unclear`) for the Form Field Guide UI + TTS.

So this dataset is best used as:

- a **multilingual field lexicon** for keyword / NER / label-normalization baselines;
- **synthetic bilingual form text** for evaluating detection / matching;
- a seed for **synthetic form generation** or weak labels—not as pixel-level layout training data by itself.

---

## Schema (summary)

### `fields.json`

```json
{
  "fields": [
    {
      "key": "name",
      "defaultLabel": "Full Name",
      "keywords": ["name", "full name", "नाम", "..."],
      "labels": { "en": "Full Name", "hi": "पूरा नाम", "...": "..." },
      "spokenHelp": { "en": "...", "hi": "...", "...": "..." }
    }
  ]
}
```

### `form_presets.json`

```json
{
  "presets": [
    {
      "id": "bank_kyc_form",
      "title": "...",
      "previewDescription": "...",
      "fullText": "Bank Customer KYC ...\\n...",
      "isForm": true
    }
  ]
}
```

See `schema.json` for formal validation.

---

## Sources for further datasets (enhance ML)

Use these to move beyond dictionary matching toward layout-aware key–value extraction, DocVQA, or Indian-form fine-tuning. **Always check the current license and terms before training or redistribution**—many are research-only or require citation.

### Document / form key–value & receipts

| Dataset | Good for | License caution |
|---------|----------|-----------------|
| **[FUNSD](https://guillaumejaume.github.io/FUNSD/)** (Form Understanding in Noisy Scanned Documents) | Scanned form entity + linking; classic baseline for form IE | Research / academic use; check FUNSD site terms |
| **[CORD](https://github.com/clovaai/cord)** (Consolidated Receipt Dataset) | Receipt key–value extraction, OCR + layout | Check Clova AI / NAVER license on the repo |
| **[SROIE](https://rrc.cvc.uab.es/?ch=13)** (ICDAR 2019) | Scanned receipt OCR + key info extraction | ICDAR competition terms; cite challenge |
| **[XFUND](https://github.com/doc-analysis/XFUND)** | Multilingual form understanding (extends FUNSD-style tasks) | Follow Microsoft/Doc-Analysis repo license |
| **ICDAR form / robust reading challenges** ([RRC](https://rrc.cvc.uab.es/)) | Scene/document text, table/form tracks over years | Per-challenge rules; often non-commercial research |

### Document VQA & classification

| Dataset | Good for | License caution |
|---------|----------|-----------------|
| **[DocVQA](https://www.docvqa.org/)** | Question answering over document images (layout + text) | Challenge / dataset terms; cite DocVQA papers |
| **[InfographicsVQA](https://www.docvqa.org/datasets/infographicvqa)** | QA on infographics (charts, dense layout) | Same family as DocVQA; check site terms |
| **[RVL-CDIP](https://adamharley.com/rvl-cdip/)** | Large-scale document *image classification* (16 classes) | Derived from IIT-CDIP; verify redistribution limits |

### Hugging Face & Document AI hubs

| Source | Good for | License caution |
|--------|----------|-----------------|
| **[Hugging Face Datasets](https://huggingface.co/datasets?task_categories=task_categories:document-question-answering)** — search `document`, `FUNSD`, `CORD`, `DocVQA`, `layoutlm` | Ready loaders; many LayoutLM / Donut fine-tune corpora | Per-dataset card (`license` field); mixed CC / custom |
| **LayoutLMv2/v3, Donut, LiLT model cards** on HF | Pretrained doc AI checkpoints + linked train sets | Model + data licenses differ; check both |
| **[DocILE](https://github.com/rossumai/docile)** / invoice-style sets | Business document key–value & line items | Competition / repo license |

### India-oriented / public government forms

| Source | Good for | License caution |
|--------|----------|-----------------|
| **[data.gov.in](https://data.gov.in/)** (Open Government Data) | Catalogs, schemas, some form-related metadata—not always scanned forms | Government open data licenses (often attribution); read each dataset |
| **[DigiLocker](https://www.digilocker.gov.in/)** public docs / issuer samples | Understanding Indian ID / certificate *layouts* users see | Do **not** scrape private user docs; use only public issuer templates / published samples; respect ToS & privacy law |
| **State / central scheme application PDFs** (scholarship, ration, e-Shram, etc.) published on official portals | Realistic bilingual EN+Indic labels for synthetic OCR | Copyright often with government; personal use / fair research vs redistribution—check portal notices; strip PII |
| **UIDAI / NPCI / bank KYC specimen PDFs** (when officially published) | Aadhaar-related / KYC field vocabulary | Strict legal constraints; never use real Aadhaar numbers; follow published specimen rules |

### Synthetic form generation (recommended bridge)

| Approach | Good for | Caution |
|----------|----------|---------|
| **Template + font render** (ReportLab, WeasyPrint, HTML→PDF, PIL) using this repo’s `fields.json` labels | Unlimited bilingual form images with known boxes | Keep synthetic IDs/PII fake; diversify fonts/noise |
| **SynthDoG / Donut-style synthetic docs** | Pretrain OCR-free DocVQA-style models | Domain gap to Indian gov forms—mix with real layouts |
| **Augment OCR dumps** from `form_presets.json` `fullText` | Quick eval set for dictionary / NER without images | Text-only; add layout later via rendering |

### Practical stack suggestion for VaakSetu

1. Keep **ML Kit OCR + dictionary** for offline on-device UX.
2. Use **FUNSD / XFUND / CORD** (+ HF loaders) to prototype a layout LM offline or on-server.
3. Seed **synthetic Indian forms** from `fields.json` + official public blank PDFs.
4. Evaluate field detection on the five `form_presets.json` texts before collecting real user photos (with consent).

---

## License of this export

VaakSetu project content. Field strings and synthetic presets are project-authored demo data (fictional personal details in filled samples). External datasets linked above remain under their own licenses.
