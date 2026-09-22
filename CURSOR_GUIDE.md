# 📜 VaakSetu (वाक् सेतु) — Complete Cursor Developer & Workflow Guide

> **Project**: VaakSetu — The Voice Bridge  
> **Repository**: [github.com/abhi-yanta/VaakSetu](https://github.com/abhi-yanta/VaakSetu)  
> **Core Purpose**: Offline-first, AI-powered document reader for rural India. Protects semi-literate users from predatory contracts, fraudulent loan papers, and illegal land deeds across 12 Indian languages using audio-first guidance.

---

## 📑 Table of Contents

1. [Project Directory Architecture](#1-project-directory-architecture)
2. [History of Work Accomplished & Solved Bugs](#2-history-of-work-accomplished--solved-bugs)
3. [Deep-Dive Technical Architecture](#3-deep-dive-technical-architecture)
   - [OCR Engine (3-Pass Multi-Script)](#a-ocr-engine-ocrservice)
   - [Deterministic Rule Engine](#b-rule-engine-ruleengine)
   - [Audio/TTS Architecture (3-Layer Fallback)](#c-tts-architecture-ttsservice)
   - [Camera Viewport & UI System](#d-camera-viewport--ui-layout)
4. [Connecting Physical Devices & Flutter Workflows](#4-connecting-physical-devices--flutter-workflows)
   - [OPPO / ColorOS USB Debugging Guide](#oppo-k12x--coloros-specifics)
   - [Standard Commands Cheat Sheet](#essential-command-line-reference)
5. [Dataset Hub (`dataset/`)](#5-dataset-hub-dataset)
6. [Critical Gotchas & Rules for Future Work](#6-critical-gotchas--rules-for-future-work)
7. [Future Roadmap](#7-future-roadmap)

---

## 1. Project Directory Architecture

The repository contains both mobile and web implementations, plus the legal ML dataset:

```
vaaksetu/
├── .cursorrules                       # Instructions automatically loaded by Cursor AI
├── CURSOR_GUIDE.md                    # This master developer guide
├── mobile/                            # ⭐ PRIMARY FOCUS: Flutter Android Application
│   ├── pubspec.yaml                   # Flutter dependencies (http, flutter_tts, camera, mlkit)
│   ├── android/                       # Native Android setup (Kotlin DSL)
│   │   ├── app/build.gradle.kts       # ML Kit model dependencies & compileSdk 36
│   │   └── app/src/main/
│   │       └── AndroidManifest.xml    # Permissions & ML Kit offline model bundling
│   ├── lib/
│   │   ├── main.dart                  # App entry, HomeScreen, Reactive AppBar speaker
│   │   ├── domain/
│   │   │   ├── models/                # DocumentAnalysis, Language, LocalizedContent
│   │   │   └── rules/rule_engine.dart # Core offline legal classification engine
│   │   ├── data/
│   │   │   ├── repositories/          # DocumentRepository
│   │   │   └── services/              # OcrService, TtsService, HapticService, PresetService
│   │   └── ui/
│   │       ├── core/                  # SecurityBadge, WaveVisualizer, TactileButton, AppColors
│   │       └── features/              # CameraScannerView, DocumentAnalyzerView, LanguageSelectorView
│   └── test/
│       ├── rule_engine_test.dart      # 8 legal domain tests + stamp paper validation
│       └── widget_test.dart           # App smoke test
├── dataset/                           # 📚 Curated Legal & ML Dataset Hub
│   ├── README.md                      # Overview & usage guide
│   ├── sources/
│   │   ├── 01_indian_kanoon/          # Real High Court & Supreme Court fraud cases
│   │   ├── 02_state_registry/         # State portals (Bhulekh, etc.) & Sale Deed samples
│   │   ├── 03_rbi_fair_practices/     # RBI Fair Practice Code rules mapped to warnings
│   │   ├── 04_cuad/                   # Atticus legal contract dataset downloader
│   │   ├── 05_claudette/              # Unfair clause patterns & explanations
│   │   └── 06_ai4bharat_indic_ocr/    # AI4Bharat catalog (Rasa, Shrutilipi, Samanantar, etc.)
│   └── synthetic/                     # 88 annotated benchmark samples (100% test accuracy)
├── client/                            # React / Vite Web & Kiosk Interface
└── server/                            # Node.js backend (express)
```

---

## 2. History of Work Accomplished & Solved Bugs

When working in this codebase, be aware of how prior bugs were resolved so you don't reintroduce regressions:

| Issue | Root Cause | Solution Applied |
|---|---|---|
| **Student Homework False-Positive** | `text.contains('land')` matched `"2-D and"` from arrays homework; classified math notebook as Safe Land Deed. | Rewrote `rule_engine.dart` with word-boundary regex (`\b...\b`), legal marker scoring, and fallback to `DocumentCategory.unrecognized` / `DocumentSeverity.unknown`. |
| **West Bengal Stamp Paper Classified as "Unclear"** | Google ML Kit lacks native Bengali; unclear threshold (<20 chars, <4 words) was too strict for partial OCR; stamp keywords missing. | 1. Added 3-pass OCR with Chinese recognizer fallback for Bengali/Assamese scripts.<br>2. Lowered threshold to `< 10 chars` / `< 2 words`.<br>3. Added stamp paper keywords (`non judicial`, `mouza`, `decimals`, `purchaser`, `vendor`, `in favour of`). |
| **Android Crash on Device (`NoClassDefFoundError`)** | ML Kit Devanagari and Chinese options classes missing from native Android runtime. | Added explicit implementations to `mobile/android/app/build.gradle.kts` and bundled models in `AndroidManifest.xml` via `com.google.mlkit.vision.DEPENDENCIES`. |
| **Camera Viewport Squished Vertically** | `CameraPreview` was placed in a fixed-size `Stack(fit: StackFit.expand)` which forcibly squished a portrait 3:4/9:16 aspect ratio into a box. | Implemented `FittedBox(fit: BoxFit.cover, child: SizedBox(width: 100, height: 100 * ratio, child: CameraPreview))` inside a 340px frame. Native aspect ratio is strictly preserved with zero distortion. |
| **Shutter Button Forced Off-Screen (Scrolling Bug)** | `AspectRatio(1 / ratio)` with unbounded height produced a ~650px tall camera card, pushing the shutter button below the fold. | Bounded the camera card to `height: 340`. Viewport + Shutter Button + Gallery Button now fit completely on a single screen without scrolling. |
| **Speaker Icon Not Responding to Mute/Play** | `main.dart` AppBar did not subscribe to `TtsService` state changes; tapping mute stopped audio but did not rebuild UI. | Refactored `TtsService` to extend `ChangeNotifier`. Used `AnimatedBuilder` on the speaker icon to dynamically flip between active (orange 🔊) and muted (gray 🔇) instantly. |

---

## 3. Deep-Dive Technical Architecture

### A. OCR Engine (`OcrService`)
*File*: `mobile/lib/data/services/ocr_service.dart`

1. **3-Pass Sequential Recognition**:
   - Pass 1: `TextRecognitionScript.devanagiri` (Primary for Hindi, Marathi, Gujarati, etc.)
   - Pass 2: `TextRecognitionScript.latin` (For English legal terms, survey numbers)
   - Pass 3: `TextRecognitionScript.chinese` (Fallback pass triggered only if Pass 1 + 2 yield < 80 characters, serving as a heuristic recognizer for complex Bengali/Assamese characters unsupported by base ML Kit).
2. **Result Merger (`_mergeResults`)**:
   - Deduplicates and merges extracted lines by line content and length.

### B. Rule Engine (`RuleEngine`)
*File*: `mobile/lib/domain/rules/rule_engine.dart`

- **Threshold Guard**: If total text has `< 10` characters or `< 2` words $\rightarrow$ `DocumentCategory.unclear` with `DocumentSeverity.unknown`.
- **Legal Marker Guard**: Text must contain recognizable legal structure markers (e.g. `affidavit`, `agreement`, `purchaser`, `borrower`, `witness`, `stamp paper`, `hereby`, `in favour of`). If missing $\rightarrow$ `DocumentCategory.unrecognized`.
- **Scoring Arrays**:
  - `loanKeywords`: `interest`, `emi`, `compound interest`, `collateral`, `foreclosure`, `ब्याज`, `कर्ज`, `गिरवी`
  - `deedKeywords`: `sale deed`, `khasra`, `mouza`, `registry`, `khatauni`, `तहसील`, `खसरा`, `रजिस्ट्री`
  - `laborKeywords`: `overtime`, `minimum wage`, `unpaid`, `bond`, `बंधुआ`, `मजदूरी`
  - `medicalKeywords`: `hospital`, `consent`, `discharge`, `waiver`, `इलाज`, `सहमति`
- **Red Flag Analysis**: Checks for predatory interest (>24%), blanket liability waivers, mandatory land forfeiture clauses, and blank check demands.

### C. TTS Architecture (`TtsService`)
*File*: `mobile/lib/data/services/tts_service.dart`

Implements `ChangeNotifier` with a 3-layer tiered fallback:
- **Layer 1: AI4Bharat via HuggingFace Inference API**
  - Model: `ai4bharat/indic-parler-tts`
  - Enabled when `HF_TOKEN` is passed via `--dart-define=HF_TOKEN=hf_xxxx`.
  - Generates natural, expressive Indian speech.
- **Layer 2: Native Device TTS (`flutter_tts`)**
  - Automatically used if no token is provided or the device is offline.
  - Utilizes Google Speech Services neural voices installed on the Android OS.
- **Layer 3: Basic Device Voice**
  - Uses reduced speech rate (`0.45`) to ensure rural users understand legal terms.

### D. Camera Viewport & UI Layout
*File*: `mobile/lib/ui/features/document_scanner/camera_scanner_view.dart`

```dart
ClipRRect(
  borderRadius: BorderRadius.circular(20),
  child: Container(
    height: 340,
    width: double.infinity,
    color: Colors.black,
    child: _isCameraReady && _cameraController != null
        ? Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              FittedBox(
                fit: BoxFit.cover,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: 100,
                  height: 100 * _cameraController!.value.aspectRatio,
                  child: CameraPreview(_cameraController!),
                ),
              ),
              // Dynamic localized frame banner
              ...
            ],
          )
        : fallbackView,
  ),
)
```

---

## 4. Connecting Physical Devices & Flutter Workflows

### OPPO K12x / ColorOS Specifics
OPPO phones have aggressive security that disconnects USB debugging after inactivity or blocks app installation:

1. **Enable Developer Options**:
   - Settings $\rightarrow$ About Phone $\rightarrow$ Tap **Build Number** 7 times.
2. **OPPO-Specific Settings (Crucial)**:
   - Settings $\rightarrow$ Additional Settings $\rightarrow$ Developer Options:
     - Turn **ON**: `USB Debugging`
     - Turn **ON**: `Disable permission monitoring` (prevents USB ADB timeouts)
     - Turn **ON**: `USB debugging (Security settings)` (allows installation via ADB)
3. **USB Connection Mode**:
   - When connecting USB, change prompt from `Charge only` $\rightarrow$ **`File Transfer (MTP)`**.

### Essential Command-Line Reference

> **⚠️ Always execute Flutter commands from inside `mobile/`!**

```powershell
# 1. Navigate to the mobile project directory
cd C:\Users\abhin\.gemini\antigravity\scratch\vaaksetu\mobile

# 2. Check if device is detected
flutter devices

# 3. Run all unit and widget tests (verify 9 passing tests)
flutter test

# 4. Run app on connected phone (Standard offline mode)
flutter run

# 5. Run app with AI4Bharat HuggingFace speech synthesis
flutter run --dart-define=HF_TOKEN=hf_your_token_here

# 6. Build standalone release APK
flutter build apk --release
# Output: mobile/build/app/outputs/flutter-apk/app-release.apk

# 7. Hot Reload / Hot Restart (in running terminal)
# Press 'r' for Hot Reload
# Press 'R' for Hot Restart
# Press 'q' to Quit

# 8. Commit and push everything to GitHub
cd ..
git add .
git commit -m "your descriptive commit message"
git push origin main
```

---

## 5. Dataset Hub (`dataset/`)

Located in `dataset/`:
- **`sources/01_indian_kanoon/`**: Real court transcripts of predatory lending and forged deed litigations.
- **`sources/02_state_registry/`**: Land deed fields, West Bengal Stamp Paper sample (`sample_sale_deed.json`), and registry portal configurations.
- **`sources/03_rbi_fair_practices/`**: Machine-readable rules for legal micro-lending caps (interest caps, harassment prevention).
- **`sources/04_cuad/`**: Downloader script for Atticus Project Contract Understanding Benchmark.
- **`sources/05_claudette/`**: Unfair arbitration and liability waiver patterns.
- **`sources/06_ai4bharat_indic_ocr/`**: Catalog of AI4Bharat models (Indic Parler-TTS, Rasa, Shrutilipi, Samanantar).
- **`synthetic/`**: 88 annotated multi-lingual document samples with `evaluate_dataset.dart` benchmark runner.

---

## 6. Critical Gotchas & Rules for Future Work

1. **Never run `flutter` in the repository root**: There is no root `pubspec.yaml`. Always run in `mobile/`.
2. **Never break 100% offline capability**: Any cloud API (e.g. HuggingFace TTS) must be purely optional and gracefully fall back to local on-device mechanisms.
3. **Always preserve `ChangeNotifier` on `TtsService`**: Do not replace `addListener` with single property callback hooks.
4. **No unbounded AspectRatio in SingleChildScrollView**: Wrapping `CameraPreview` with raw aspect ratio forces full-height expansion and breaks layout on tall phone screens.
5. **Keep ML Kit native dependencies synchronized**: If adding new script recognition (e.g. Japanese or Korean), you must add both Gradle dependencies in `build.gradle.kts` and meta-data tags in `AndroidManifest.xml`.

---

## 7. Future Roadmap

- [ ] **Document Perspective Cropper**: Add OpenCV / custom edge detection so tilted phone captures are automatically straightened and enhanced before OCR.
- [ ] **Multi-Page Scanning**: Allow scanning front and back of multi-page stamp paper deeds.
- [ ] **On-Device Quantized Indic TTS**: Package an ONNX-runtime based quantized TTS model directly in the APK for high-fidelity offline synthesis.
