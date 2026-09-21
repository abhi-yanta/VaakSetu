# VaakSetu Mobile (वाक् सेतु) 📱🇮🇳

The offline-first, AI-powered document accessibility mobile application for Android.

Designed specifically for non-literate and semi-literate Indian citizens, daily-wage workers, and rural communities to protect them from signing fraudulent loan agreements, predatory land deeds, exploitative labor contracts, and liability waivers.

---

## 🚀 Key Mobile Capabilities

1. **Audio-First Tactile Interface**:
   - Zero literacy required to navigate.
   - Large touch targets (minimum 64dp) with high-contrast (WCAG AAA compliant) color schemes.
   - Haptic vibration feedback for tactile cues (light click on button tap, double vibration on warning, triple alert pulse on danger).
   - Animated **WaveVisualizer** providing visual feedback while speech synthesis is active.

2. **On-Device Optical Character Recognition (OCR)**:
   - Uses **Google ML Kit Text Recognition** running 100% locally on-device.
   - Dual recognizers for Latin and Devanagari / Indic scripts.
   - Zero internet or cellular data needed.

3. **Predatory Clause Rules Engine**:
   - **Loan Agreements**: Flags APR > 24%, monthly compound interest, advance fee deductions, and agricultural land mortgage/seizure clauses.
   - **Land Deeds (*Khasra / Khatauni*)**: Detects irrevocable power-of-attorney transfers and missing spousal/co-owner consents.
   - **Labor Contracts**: Catches 12-hour mandatory work shifts, unpaid overtime, and bonded labor resignation penalties.
   - **Hospital Forms**: Flags total release of liability and negligence immunity clauses.

4. **12 Indian Languages Spoken via Native TTS**:
   - Speaks in **Hindi, Tamil, Telugu, Marathi, Bengali, Gujarati, Kannada, Malayalam, Odia, Punjabi, Assamese, and Urdu**.
   - Includes full voice prompts and individual warning narration buttons.

5. **Built-in Offline Test Presets**:
   - Test high-risk loans, safe deeds, labor bonds, and medical waivers instantly even without physical documents.

---

## 🏗️ Architecture

```
mobile/
├── pubspec.yaml                 # Flutter dependencies (camera, mlkit, tts, vibration)
├── assets/
│   └── presets/presets.json     # Offline document presets
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml  # Camera, audio, vibration permissions
├── lib/
│   ├── main.dart                # Application entrypoint & view controller
│   ├── data/
│   │   ├── services/
│   │   │   ├── ocr_service.dart      # Google ML Kit on-device OCR
│   │   │   ├── tts_service.dart      # Native Text-to-Speech wrapper
│   │   │   ├── haptic_service.dart   # Tactile vibration patterns
│   │   │   └── preset_service.dart   # Offline test document loader
│   │   └── repositories/
│   │       └── document_repository.dart
│   ├── domain/
│   │   ├── models/
│   │   │   ├── language.dart         # 12 Indic languages metadata & locales
│   │   │   ├── document_analysis.dart # Severity & category enums
│   │   │   └── localized_content.dart # Vernacular translations & voice scripts
│   │   └── rules/
│   │       └── rule_engine.dart      # Predatory clause & fraud detector
│   └── ui/
│       ├── core/
│       │   ├── app_colors.dart       # High-contrast accessibility palette
│       │   ├── tactile_button.dart   # Big touch target button with haptics
│       │   ├── wave_visualizer.dart  # Dynamic sine wave canvas painter
│       │   └── security_badge.dart   # Green / Yellow / Red alert card
│       └── features/
│           ├── language_selection/   # Welcome & 12-language grid
│           ├── document_scanner/     # Camera viewfinder & gallery picker
│           └── document_analyzer/    # Risk breakdown, audio controls & warnings
└── test/
    └── rule_engine_test.dart        # Unit tests for vulnerability detection
```

---

## ⚡ How to Run & Build

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.10+)
- Android Studio with Android SDK (API 21+)
- Android device or emulator with camera support

### 1. Get Dependencies
```bash
cd mobile
flutter pub get
```

### 2. Run Unit Tests
```bash
flutter test
```

### 3. Run on Connected Device / Emulator
```bash
flutter run
```

### 4. Build Release APK
```bash
flutter build apk --release
```
The output APK will be generated at `build/app/outputs/flutter-apk/app-release.apk`.
