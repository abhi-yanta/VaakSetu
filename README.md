# VaakSetu (वाक् सेतु) — The Voice Bridge

Audio-first Android app that helps low-literacy and rural users understand legal papers and forms before they sign. Point a phone camera at a document → on-device OCR → spoken safety summary (or field-by-field form help) in the user’s language.

**Primary product:** Flutter app in [`mobile/`](mobile/) (v1.0.0).  
**Repository:** https://github.com/abhi-yanta/VaakSetu

---

## What it does

| Mode | Behavior |
|---|---|
| **Document safety** | Scan or pick a loan / deed / job / medical paper. Rule engine classifies category and severity (safe / warning / danger / unknown), highlights risky clauses, and speaks an elaborate narrative plus tap-to-replay warnings. |
| **Form Field Guide** | Scan a KYC-style or government form. Match labels to known fields and walk through each blank with spoken help. |

**Also included:**

- **12 Indian languages** — Hindi, Tamil, Telugu, Marathi, Bengali, Gujarati, Kannada, Malayalam, Odia, Punjabi, Assamese, Urdu (UI + TTS prompts)
- **Mascot welcome tour** — character pages after first language pick, with TTS and Shorts-style synced captions
- **Full-screen camera scanner** — live viewfinder, gallery, flash, framing prompts; offline **demo presets** so demos work without printed paper
- **On-device OCR** — Google ML Kit (documents stay on the phone for analysis)
- **Rule-engine clause highlights** — deterministic checks (e.g. high interest, land collateral, bonded-labor style clauses, blanket medical waivers) — not an LLM lawyer
- **Listen again** — replay controls on guided screens and AppBar
- **Cream vernacular UX** — large targets, green / amber / red severity, haptics

Core OCR + rules run offline. Online TTS (Bhashini / Hugging Face) is optional; without keys the app still speaks via **device TTS**.

There is **no speech-to-text / voice-command** pipeline today — interaction is tap + spoken playback.

---

## Tech stack

| Layer | Choice |
|---|---|
| App | Flutter 3.x / Dart (`vaaksetu_mobile`) |
| OCR | `google_mlkit_text_recognition` |
| Camera / gallery | `camera`, `image_picker` |
| TTS | Device-first (`flutter_tts`) for instant speech; optional Bhashini / Hugging Face AI4Bharat voices prefetch for later plays (`audioplayers`, `http`) |
| State | `provider` / `ChangeNotifier`, `shared_preferences` |
| Haptics | `vibration` |

Secondary / legacy: React + Vite client (`client/`) and Express kiosk helper (`server/`) for browser/CSC demos. Feature parity lags the Flutter app.

---

## Repo structure

```
vaaksetu/
├── mobile/          # Flagship Flutter Android app
│   ├── lib/         # UI, domain (rules, forms), data (OCR, TTS)
│   ├── assets/      # Presets, mascot, form-guide export, icon
│   ├── tool/        # run_with_env.ps1 and tooling
│   └── .env.example # Optional TTS key placeholders
├── dataset/         # Legal / OCR sources + synthetic rule benchmarks
├── client/          # React web UI (kiosk / CSC path)
├── server/          # Express companion for the web client
├── docs/            # Product overview and notes
└── VAAKSETU_SYSTEM_DESCRIPTION.md
```

Deeper product walkthrough: [`docs/VaakSetu_Overview.md`](docs/VaakSetu_Overview.md).

---

## Run the Flutter app

### Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) 3.x
- Android SDK / Studio (min SDK 21)
- Phone or emulator (camera optional if you use presets)

### Install and launch

```powershell
cd mobile
flutter pub get
flutter test
flutter run
```

Release APK:

```powershell
cd mobile
flutter build apk --release
# → mobile/build/app/outputs/flutter-apk/app-release.apk
```

### Optional online TTS (Bhashini / Hugging Face)

Copy the example env file, fill in **your own** keys locally, then launch with the helper script (values are passed as `--dart-define`; never commit real secrets):

```powershell
cd mobile
Copy-Item .env.example .env
# Edit .env — leave blank keys unused
.\tool\run_with_env.ps1
```

Placeholders in [`mobile/.env.example`](mobile/.env.example):

```
BHASHINI_USER_ID=
BHASHINI_UDYAT_KEY=
BHASHINI_INFERENCE_KEY=
HF_TOKEN=
```

**Speech path:** device TTS starts immediately (no silent wait on the network). When Bhashini / HF keys are set, higher-quality audio is prefetched in the background and used on cache hit for the next play of that text.

---

## Web / kiosk path (optional)

```bash
cd server && npm install && npm start   # typically :5000
cd client && npm install && npm run dev # typically :3000
```

Use this for shared-laptop / hotspot demos. For rural voice-first UX, prefer `mobile/`.

---

## Honest limits

- Legal analysis is **keyword / rule-based**, not a substitute for a lawyer.
- OCR quality depends on lighting, stamp fonts, and script coverage.
- Form blank placement is heuristic, not a trained layout model.
- Best cloud voices need network + configured keys; offline speech uses device TTS.

---

## License / contribution

See repository settings and existing project docs for contribution and licensing details. Do not commit `.env` files or API keys.
