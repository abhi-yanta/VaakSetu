# VaakSetu — 3D Workflow Landing

React 19 + Vite + TypeScript + Tailwind CSS v4 + Framer Motion + **React Three Fiber** / Drei landing page, structured like [reactjs18-3d-portfolio](https://github.com/ladunjexa/reactjs18-3d-portfolio) but for the **real VaakSetu product flow** (not a personal portfolio copy).

Steps are derived from `mobile/lib/main.dart` (`AppView`) with `kFormGuideEnabled = false`.

## Run

```bash
cd landing
npm install
npm run dev
```

Build:

```bash
npm run build
npm run preview
```

Themes via query or navbar:

- [http://localhost:5173/?theme=a](http://localhost:5173/?theme=a) — dark tech (`#1a1d1f`, nav `#001529`, teal accent `#2dd4bf`)
- [http://localhost:5173/?theme=b](http://localhost:5173/?theme=b) — Flutter app cream `#F7F3EB` / saffron `#E65100` / teal `#00695C`

## Real workflow order (code wins)

With `kFormGuideEnabled = false`:

1. **Welcome** → Start  
2. **Language** (12 languages)  
3. **Feature tour** (first time only)  
4. **Camera scanner** (no mode chooser)  
5. **Loading** (OCR + rule analysis)  
6. **Analyzer results** (TTS + captions + listen again)

Form Field Guide / mode chooser exist in the repo but are **disabled** and are not workflow steps here. No STT.

## Step → source files

| Step | Source files |
|------|----------------|
| 01 Welcome | `mobile/lib/main.dart` (`AppView.welcome`), `mobile/lib/ui/features/language_selection/welcome_view.dart`, `mobile/lib/ui/core/animated_logo.dart` |
| 02 Language | `mobile/lib/main.dart` (`_onStart`), `mobile/lib/ui/features/language_selection/language_selector_view.dart`, `mobile/lib/domain/models/language.dart` |
| 03 Feature tour | `mobile/lib/main.dart` (`_onLanguageSelected` → `featureTour`), `mobile/lib/ui/features/language_selection/character_welcome_view.dart`, `mobile/lib/domain/models/localized_content.dart` |
| 04 Scanner | `mobile/lib/main.dart` (`_openDocumentScanner`, `kFormGuideEnabled`), `mobile/lib/ui/features/document_scanner/camera_scanner_view.dart` |
| 05 Analyze | `mobile/lib/main.dart` (`_processImage` → `loading`), `mobile/lib/data/repositories/document_repository.dart`, `mobile/lib/ui/core/animated_logo.dart` |
| 06 Results | `mobile/lib/main.dart` (`AppView.analyzer`), `document_analyzer_view.dart`, `speaking_caption_footer.dart`, `listen_again_button.dart`, `tts_service.dart` |

Step definitions live in `src/constants/index.ts` (`STEPS` array — single source of truth).

## Project structure

```
src/
  components/
    canvas/     Ball, Phone, Stars, StarsCanvas, Loader
    layout/     Navbar, DotNavigator, BackToTop
    sections/   Hero, StepSection, Languages, Features
  constants/    STEPS, LANGUAGES, FEATURES
  hoc/          SectionWrapper (scroll-triggered motion)
  hooks/        useTheme (?theme=a|b)
  utils/        motion.ts (fadeIn, slideIn, staggerContainer, …)
```

## Screens / textures

Phone screen textures:

| File | Screen |
|------|--------|
| `public/assets/steps/step-01-welcome.png` | Welcome |
| `public/assets/steps/step-02-language.png` | Language grid |
| `public/assets/steps/step-03-feature-tour.png` | Feature tour |
| `public/assets/steps/step-04-scanner.png` | Camera scanner |
| `public/assets/steps/step-05-loading.png` | Analyzing |
| `public/assets/steps/step-06-results.png` | Analyzer |

Replace placeholders with real Android captures (same filenames). Brand: `public/brand/` (Option 4 mark / lockup / app icon).

## 3D notes

- No `phone.glb` — procedural `RoundedBox` + screen plane + texture (`Phone.tsx`).
- Desktop: R3F canvas with slow rotate / mouse parallax / scroll tilt.
- Mobile / `prefers-reduced-motion`: static PNG instead of canvas; stars lazy-mounted.
- Language bubbles: `Ball.tsx`-style icosahedrons with native-script canvas textures.

## Caveats

- No STT / voice commands in the Flutter app — do not claim them.
- Form Guide is **off**; after tour the app goes straight to the scanner.
- Overview docs that still show a mode chooser are outdated vs current `main.dart`.
