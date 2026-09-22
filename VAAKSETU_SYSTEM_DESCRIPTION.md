# 📖 VaakSetu (वाक् सेतु) — Complete System & Domain Description

> **Project Name**: VaakSetu (The Voice Bridge / वाक् सेतु)  
> **Repository**: [https://github.com/abhi-yanta/VaakSetu](https://github.com/abhi-yanta/VaakSetu)  
> **Tagline**: The Voice Bridge for Legal & Document Safety in Rural India  
> **Core Mission**: To protect illiterate, semi-literate, and rural citizens of India from predatory contracts, fraudulent loan papers, and illegal land grabs by translating complex legal documents into instant, understandable spoken warnings in their native mother tongue — 100% offline, private, and on-device.

---

## 1. The Origin & Meaning of the Name

- **वाक् (Vaak)**: Sanskrit/Hindi for *Voice*, *Speech*, or *The Spoken Word*.
- **सेतु (Setu)**: Sanskrit/Hindi for *Bridge*.
- **VaakSetu (The Voice Bridge)**: Bridges the critical gap between complex, printed, exploitative legal language (frequently written in English or legalistic legalese) and rural citizens who cannot read or write, communicating life-or-death financial and property warnings through **speech and sound**.

---

## 2. The Problem Landscape: Why VaakSetu Exists

In rural and semi-urban India, more than **250 million people** are functionally illiterate or possess low literacy. When entering into contracts, they face severe systemic risks:

1. **Predatory Micro-Lending & Debt Traps**:
   - Private moneylenders and unregulated microfinance entities issue loan papers with annual interest rates between **36% to 120% APR** (often masked as "3% to 10% per month").
   - Borrowers are pressured into signing blank pages, giving post-dated blank checks, or signing clauses that allow lenders to seize family land or livestock upon a single missed payment.

2. **Land Grabs & Disguised Deeds**:
   - Illiterate farmers often believe they are signing a simple mortgage or loan receipt, while the paper is actually an **Irrevocable General Power of Attorney (GPA)** or an outright **Sale Deed (बिक्री पत्र / सफ़-कबाला)** transferring ownership of their ancestral agricultural land (*Mouza*, *Khasra*, *Khatauni*).
   - Real stamp papers (like West Bengal Rs. 5000 non-judicial stamp papers) contain archaic legal formulas in small fonts that villagers cannot decipher.

3. **Exploitative Labor Contracts & Bonded Labor**:
   - Brick kiln workers, construction laborers, and agricultural migrants sign contracts enforcing unpaid overtime, wage retention, or restriction of freedom of movement until advance debts are paid off (unlawful bonded labor).

4. **Blanket Medical & Hospital Waivers**:
   - Patients or their relatives in rural clinics are forced to sign forms during medical emergencies that waive all liability for gross negligence, medical malpractice, or accidental death.

5. **Lack of Rural Internet Connectivity**:
   - Villages and agricultural fields frequently have zero cellular data connectivity or spotty 2G. A solution that relies on cloud servers, external OpenAI/Gemini endpoints, or network requests will fail when the farmer needs it most.

---

## 3. Core Design Principles

Every line of code and UI element in VaakSetu adheres to three non-negotiable principles:

### Principle 1: 100% Offline-First (Zero Data Leakage, Zero Cloud Dependency)
- The user's land deeds, identity cards, financial agreements, and private documents **never leave the physical device**.
- OCR runs locally on the phone's CPU/NPU via Google ML Kit.
- Document analysis and clause evaluation run locally in pure Dart.
- Text-to-Speech uses on-device system neural voices, with an optional internet-based HuggingFace AI4Bharat model when connectivity is available.

### Principle 2: Audio, Haptic & Visual First (Accessible for Illiterate Users)
- A user who cannot read a single letter must still be able to protect their land and money.
- **Audio Announcements**: The app speaks every warning aloud automatically.
- **Color Coding**: 
  - 🟢 **Green (Safe)**: Standard balanced agreement with fair terms.
  - 🟡 **Yellow (Warning)**: Document contains unusual clauses or risks; user must proceed with caution.
  - 🔴 **Red (Danger)**: Predatory clauses found (high interest, asset forfeiture, blank signatures). **"डू नॉट साइन / हस्ताक्षर न करें"** is spoken immediately.
  - 🔵 **Cyan (Info/Unrecognized)**: The paper is a student notebook, drawing, or non-legal document. The app clearly states this is not an official legal paper.
- **Haptic Feedback**: High-frequency urgent vibrations for Red Flag contracts; calm light taps for safe actions.

### Principle 3: Strict Safety Guardrails (Never Cry Wolf, Never False-Reassure)
- An ambiguous or non-legal piece of paper (e.g. handwritten school notes, shopping list) must **NEVER** display a green "Safe to Sign" checkmark.
- The rule engine uses rigorous multi-marker scoring so that non-legal text is categorized as `unrecognized`, while unreadable or blurry text is categorized as `unclear`.

---

## 4. Complete System Architecture

VaakSetu consists of three interdependent components:

```
                      ┌────────────────────────────────────────┐
                      │              VaakSetu Hub              │
                      └───────────────────┬────────────────────┘
                                          │
        ┌─────────────────────────────────┼────────────────────────────────┐
        │                                 │                                │
        ▼                                 ▼                                ▼
┌─────────────────┐             ┌───────────────────┐            ┌────────────────────┐
│   Mobile App    │             │   Web & Kiosk     │            │   ML & Legal Hub   │
│   (Flutter)     │             │  (React + Node)   │            │     (dataset/)     │
└─────────────────┘             └───────────────────┘            └────────────────────┘
 • 100% Offline Android         • CSC / Gram Panchayat           • 6 Legal Sources
 • 12 Indian Languages            Legal Aid Kiosks               • 88 Benchmark Cases
 • Triple-Pass ML Kit OCR       • Responsive Desktop/Tablet      • RBI FPC & Kanoon
 • 3-Layer TTS Engine           • Client Rule Engine             • Evaluation Scripts
 • Haptics & Visualizer
```

### Component A: Flutter Mobile Application (`/mobile`)

The flagship product of VaakSetu, running natively on Android devices (optimized for budget smartphones such as OPPO K12x, Redmi, Realme, Samsung Galaxy M/F series).

#### 1. Language Support (12 Major Indian Languages)
Each language has complete, culturally adapted translations for all UI strings, voice prompts, and legal risk explanations:
1. **Hindi (हिन्दी - `hi`)**
2. **Tamil (தமிழ் - `ta`)**
3. **Telugu (తెలుగు - `te`)**
4. **Marathi (मराठी - `mr`)**
5. **Bengali (বাংলা - `bn`)**
6. **Gujarati (ગુજરાતી - `gu`)**
7. **Kannada (ಕನ್ನಡ - `kn`)**
8. **Malayalam (മലയാളം - `ml`)**
9. **Odia (ଓଡ଼ିଆ - `or`)**
10. **Punjabi (ਪੰਜਾਬੀ - `pa`)**
11. **Assamese (অসমীয়া - `as`)**
12. **Urdu (اردو - `ur`)**

#### 2. Triple-Pass OCR Pipeline (`OcrService`)
*File*: `mobile/lib/data/services/ocr_service.dart`

To overcome the challenge that mobile OCR engines often struggle with Indian scripts and non-standard stamp paper layouts, VaakSetu uses a 3-recognizer cascade:
1. **Devanagari Script Engine** (`TextRecognitionScript.devanagiri`): Extracts Hindi, Marathi, Sanskrit, and northern Indic scripts.
2. **Latin Script Engine** (`TextRecognitionScript.latin`): Extracts survey numbers, currency amounts, English clauses, legal citations.
3. **Chinese Heuristic Fallback** (`TextRecognitionScript.chinese`): If Passes 1 and 2 produce fewer than 80 characters, Pass 3 executes to capture complex Bengali, Assamese, or eastern regional glyphs that would otherwise be missed.
4. **Intelligent Line Merger (`_mergeResults`)**: Sorts candidates, eliminates duplicate fragments, and merges text lines while preserving document reading order.

#### 3. Deterministic Legal Rule Engine (`RuleEngine`)
*File*: `mobile/lib/domain/rules/rule_engine.dart`

The core intelligence that replaces opaque cloud LLMs with 100% explainable, deterministic legal analysis:
- **Minimum Word/Char Verification**: If extracted text has `< 10` characters or `< 2` words, the analysis is flagged as `unclear` ("पन्ना स्पष्ट नहीं है").
- **Legal Marker Scoring**: Computes presence of essential formal legal terms (`agreement`, `affidavit`, `witness`, `schedule`, `hereinafter`, `stamp paper`, `purchaser`, `borrower`, etc.). If score is below threshold, returns `unrecognized` ("यह कोई कानूनी दस्तावेज़ नहीं है").
- **Document Categorization**:
  - `DocumentCategory.loan`: Promissory notes, bank loans, microfinance agreements, informal debt receipts.
  - `DocumentCategory.deed`: Land sale deeds, gift deeds, mortgage deeds, lease agreements, stamp paper transfers.
  - `DocumentCategory.job`: Employment contracts, agricultural labor bonds, daily wage agreements.
  - `DocumentCategory.medical`: Consent forms, surgical waivers, hospital discharge liability waivers.
  - `DocumentCategory.unrecognized`: Non-legal documents (notebooks, letters, receipts, random text).
  - `DocumentCategory.unclear`: Blurry photos, low-light captures, empty pages.
- **Severity Evaluation**:
  - `DocumentSeverity.safe`: Fair, balanced document with standard statutory protections.
  - `DocumentSeverity.warning`: Contains terms requiring clarification (e.g. high processing fee, short cure periods).
  - `DocumentSeverity.danger`: Contains illegal or predatory clauses (interest > 24%, land collateral for microloan, blank signatures, total liability waiver).
  - `DocumentSeverity.unknown`: Unclear or unrecognized document.

#### 4. Three-Layer Audio/TTS Architecture (`TtsService`)
*File*: `mobile/lib/data/services/tts_service.dart`

- **Architecture**: Implements Flutter's `ChangeNotifier` so UI elements (e.g. top-right AppBar speaker button, visualizer waveforms) stay synchronized in real time.
- **Layer 1 (AI4Bharat Parler-TTS)**:
  - Connects to `ai4bharat/indic-parler-tts` hosted on HuggingFace when `HF_TOKEN` is supplied.
  - Produces expressive, slow, authoritative native Indian voices.
- **Layer 2 (Android Device Neural TTS)**:
  - Uses the Google Speech Services engine pre-installed on Android 9+.
  - Works 100% offline with high quality for Hindi, Tamil, Telugu, Marathi, Bengali, etc.
- **Layer 3 (Fallback Slow Rate)**:
  - Decreases speech rate to `0.45` so rural users unfamiliar with rapid legal terms can hear every syllable distinctly.

#### 5. Camera & Viewport Experience (`CameraScannerView`)
*File*: `mobile/lib/ui/features/document_scanner/camera_scanner_view.dart`

- **Compact Viewport (340px)**: The camera preview uses `BoxFit.cover` inside a bounded 340px container. This prevents vertical or horizontal distortion (no squished faces or stretched text).
- **Zero-Scroll Viewfinder**: The camera framing, orange circular shutter button (72px), and gallery upload button all fit on a single screen without needing to scroll.
- **Localized Framing Guide**: A dynamic banner over the viewfinder guides the user in their selected language (e.g., Hindi: *"दस्तावेज़ को चौखट के अंदर रखें"*, Urdu: *"دستاویز کو فریم کے اندر رکھیں"*).
- **Demo Presets**: Pre-loaded real-world legal documents (predatory loan, safe land deed, labor bond, medical waiver) for instant testing and training.

---

### Component B: Web & Kiosk Interface (`/client` & `/server`)

- **Purpose**: For village common service centers (CSCs), Gram Panchayat offices, and legal aid volunteer clinics using laptop or desktop computers.
- **Frontend**: React + Vite + Tailwind CSS + Lucide Icons.
- **Backend**: Node.js Express server providing fallback analysis and document storage capabilities when run in an institutional kiosk environment.

---

### Component C: Legal & ML Dataset Hub (`/dataset`)

VaakSetu maintains a dedicated legal knowledge base combining 6 real-world legal databases:

1. **`01_indian_kanoon`**: Search templates and case excerpts from the Supreme Court of India and State High Courts concerning predatory money lending acts and forged sale deed litigations.
2. **`02_state_registry`**: Real stamp paper structures (including West Bengal Rs. 5000 Non-Judicial Stamp Paper, Murshidabad deed) and mandatory land deed checklists (*Mouza, J.L. No, Khatian, Plot, Decimals*).
3. **`03_rbi_fair_practices`**: Machine-readable rules from the Reserve Bank of India (RBI) Fair Practices Code for NBFCs and Microfinance Institutions (MFI caps, anti-harassment regulations).
4. **`04_cuad`**: Contract Understanding Atticus Dataset converter for mapping Western legal clauses to Indian rural contracts.
5. **`05_claudette`**: Unfair contract clause patterns (arbitration denial, unilateral modification, blanket indemnity).
6. **`06_ai4bharat_indic_ocr`**: Comprehensive catalog of IIT Madras AI4Bharat models and datasets (Shrutilipi, Rasa, Samanantar, Aksharantar, Naamapadam, IndicOCR).
7. **`synthetic/`**: 88 fully annotated test cases with `evaluate_dataset.dart` achieving 100% precision and recall on legal classification benchmarks.

---

## 5. Domain Rules: What Makes a Document "Dangerous"?

When VaakSetu inspects a document, it evaluates specific legal markers:

| Document Type | Safe Condition (🟢) | Red Flag / Danger Condition (🔴) |
|---|---|---|
| **Loan Agreement** | Interest rate $\le 18\%$ APR, clear EMI schedule, regulated bank/NBFC name, written receipt clause. | Interest $> 24\%$ APR, compound daily/monthly interest, demand for blank signed checks, land/house deed pledged as collateral for small loans, power to seize crops/cattle without court order. |
| **Land Deed (Sale/Gift/Lease)** | Clear consideration (sale price paid), mutual consent stated, survey numbers verified, boundary demarcation recorded, both parties identified. | Disguised Sale Deed where user thought it was a loan, Irrevocable Power of Attorney granting full transfer rights, waiver of seller's right to challenge in court, missing payment details. |
| **Labor Contract** | Specified working hours (8 hrs/day), minimum wage compliance, overtime compensation, right to resign with notice. | Wage withholding until end of season, debt-bondage clause ("cannot work elsewhere until loan repaid"), mandatory unpaid overtime, restriction on leaving premises. |
| **Medical Waiver** | Informed consent for specific surgical procedures, explanation of standard risks. | Complete waiver of hospital liability for negligence, surgeon malpractice, or medical error; waiver of consumer forum recourse. |
| **Non-Legal / Notes** | Marked as `unrecognized` (🔵). Clear voice guidance explaining this is not a legal document. | Never falsely classified as a safe contract. |

---

## 6. How to Run & Verify VaakSetu

### Directory Rule
> **Always run mobile commands from within the `mobile/` directory.**

```powershell
# Navigate to mobile app
cd C:\Users\abhin\.gemini\antigravity\scratch\vaaksetu\mobile

# 1. Run full test suite (9 automated tests)
flutter test

# 2. Run app on connected phone (offline mode)
flutter run

# 3. Run app with AI4Bharat HuggingFace TTS enabled
flutter run --dart-define=HF_TOKEN=hf_your_token_here

# 4. Build release APK for direct sharing/install
flutter build apk --release
# APK is located at: mobile/build/app/outputs/flutter-apk/app-release.apk
```

---

## 7. Summary for AI Agents & Developers

When creating features or fixing bugs in VaakSetu:
1. **Preserve offline independence**: Never assume the device has internet.
2. **Prioritize the illiterate end-user**: Ensure every message is clear, simple, and spoken aloud.
3. **Respect legal precision**: Never weaken the threshold for detecting predatory interest or land theft.
4. **Maintain multi-lingual equality**: Every UI update and warning must be supported across all 12 Indian languages in `LocalizedContent`.
