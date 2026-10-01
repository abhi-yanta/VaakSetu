# VaakSetu company website (second landing)

Evidence-first company landing modeled after detailing patterns (eyebrow, italic accent, facts grids, status pills) — **not** a clone of another product’s claims.

## Two landings in this repo

| # | Path | Role |
|---|---|---|
| **1 (first)** | [`../landing/`](../landing/) | 3D / workflow portfolio landing — **keep intact** |
| **2 (this)** | `website/` | Company-style detailing page (this app) |

Do not replace or gut `landing/` when working on `website/`.

## Run

```bash
cd website
npm install
npm run dev
```

Build:

```bash
cd website
npm run build
```

Themes: navbar toggle, `data-theme="a|b"`, or `?theme=a` / `?theme=b`.

- **Theme A** — dark tech AntMotion (nav `#001529`, bg `#1a1d1f`, teal accents)
- **Theme B** — Flutter cream / saffron / teal (`#F7F3EB`, `#E65100`, `#00695C`)

## Honest product notes (from code)

- First-run path with `kFormGuideEnabled = false`: **Welcome → Language → Feature tour → Scanner → Loading → Results**
- Form Field Guide + mode chooser are **off** in the current build flag (`mobile/lib/main.dart`)
- No STT / voice commands
- OCR + rules on-device; optional Bhashini / Hugging Face TTS needs keys

Fill placeholders via the browser form: open `public/placeholders-form.html` (or `npm run dev` then `/placeholders-form.html`), export JSON/MD, and paste into Cursor chat with any listed image attachments.

## PLACEHOLDER list (fill with evidence only)

1. Hero status chip — `PLACEHOLDER: Building / Hackathon finalist…` (no award evidence in repo)
2. Recognition logos — hackathon, college, partner SVG slots under `public/assets/logos/`
3. Audience — CSC partnership claim; named NGO partners; bank deployment claims
4. Traction cards — photos, captions, all fact values
5. Traction counters — none yet (intentionally empty; no fake Team-reported numbers)
6. Team — photo / name / role / LinkedIn × 3
7. CTA form — backend submit endpoint; privacy policy URL
8. Footer Connect — email, Twitter/X, LinkedIn page
9. Footer location — city / region
10. Form consent / early-access privacy policy URL

Tool logos labeled Flutter / ML Kit / Bhashini reflect real stack names but still use placeholder artwork until official marks are licensed.

## Section → source mapping

| Section | Sources |
|---|---|
| Hero / navbar | `README.md`, `docs/VaakSetu_Overview.md`, `docs/brand/`, `mobile/pubspec.yaml` |
| Recognition strip | Placeholder logos; tool names from `pubspec.yaml` / TTS service |
| Problem | `docs/VaakSetu_Overview.md` §2–4, `README.md` |
| Where it fits | `main.dart` pipeline, `ocr_service.dart`, `rule_engine.dart`, `tts_service.dart` |
| Full workflow | `mobile/lib/main.dart` (`AppView`, `kFormGuideEnabled`), welcome / language / tour / scanner / analyzer views |
| Screens carousel | `landing/public/assets/steps/` copies → `public/assets/steps/` |
| Languages | `mobile/lib/domain/models/language.dart` (12) |
| Document types | `document_analysis.dart`, `preset_service.dart`, `rule_engine.dart`, Form Guide flag |
| Who it’s for | Overview §3; CSC via `client/`+`server/` note |
| Under the hood | `pubspec.yaml`, `AndroidManifest.xml`, `ocr_service.dart`, `tts_service.dart`, `rule_engine.dart` |
| Evidence | README honest limits, Overview §17 |
| Traction | No evidenced awards/metrics in repo → placeholders |
| Roadmap | Overview §16–17 + `kFormGuideEnabled` |
| Team | No roster in docs → placeholders |
| FAQ | Same sources as above |
| CTA / footer | GitHub URL from README; form backend placeholder |

## Stack

React + Vite + TypeScript + Tailwind CSS v4 + Framer Motion. Typed content under `src/content/`. One component per section under `src/components/sections/`.
