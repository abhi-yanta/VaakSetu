import type { StatusKind } from './hero'

export type WorkflowStep = {
  number: string
  id: string
  category: string
  title: string
  description: string
  userDoes: string
  appDoes: string
  tech: string
  screenshot: string
  screenshotNote: string
  facts: { label: string; value: string }[]
  status: StatusKind
}

/**
 * Real first-run order with kFormGuideEnabled = false:
 * Welcome → Language → Feature tour → Scanner → Loading → Results.
 * Mode chooser / Form Guide are skipped.
 */
export const workflowContent = {
  eyebrow: 'Full workflow',
  headlineBefore: 'First-run order as',
  headlineAccent: 'verified in main.dart.',
  intro:
    'With kFormGuideEnabled = false, the app opens the document scanner after the feature tour — no mode chooser. Form Field Guide remains in the codebase but is not on this path.',
  flagNote:
    'Honest build flag: const bool kFormGuideEnabled = false — Form Guide + “क्या करना है” mode chooser are temporarily disabled.',
  steps: [
    {
      number: '01',
      id: 'welcome',
      category: 'Onboarding',
      title: 'Welcome',
      description: 'Brand entry with वाक् सेतु title and a Start control.',
      userDoes: 'Taps Start to begin.',
      appDoes: 'Opens language selection; TTS warms after first paint.',
      tech: 'welcome_view.dart · AppView.welcome',
      screenshot: '/assets/steps/step-01-welcome.png',
      screenshotNote: 'App screenshot · welcome',
      facts: [
        { label: 'Entry', value: 'AppView.welcome' },
        { label: 'Theme', value: 'Cream light (AppColors)' },
        { label: 'TTS', value: 'Warm-up after first frame' },
        { label: 'Haptics', value: 'Light tap on Start' },
      ],
      status: 'working',
    },
    {
      number: '02',
      id: 'language',
      category: 'Onboarding',
      title: 'Language',
      description: 'Twelve-language grid with script-character badges (not flag emoji).',
      userDoes: 'Picks one of 12 Indian languages.',
      appDoes: 'Stores language; first pick routes to feature tour.',
      tech: 'language_selector_view.dart · Language.supportedLanguages',
      screenshot: '/assets/steps/step-02-language.png',
      screenshotNote: 'App screenshot · language grid',
      facts: [
        { label: 'Count', value: '12 languages' },
        { label: 'UI + TTS', value: 'LocalizedContent prompts' },
        { label: 'Badges', value: 'Script characters' },
        { label: 'Replay', value: 'Listen-again control' },
      ],
      status: 'working',
    },
    {
      number: '03',
      id: 'tour',
      category: 'Onboarding',
      title: 'Feature tour',
      description: 'Mascot pages after first language pick: scan, safety, languages.',
      userDoes: 'Swipes or continues through mascot tour pages.',
      appDoes: 'Speaks each page; Form Guide tour page omitted while flag is off.',
      tech: 'character_welcome_view.dart · VaakSetuMascot',
      screenshot: '/assets/steps/step-03-feature-tour.png',
      screenshotNote: 'App screenshot · feature tour',
      facts: [
        { label: 'Pages now', value: 'Scan · Safety · Languages' },
        { label: 'Skipped page', value: 'Forms (while Form Guide off)' },
        { label: 'Captions', value: 'Shorts-style synced captions' },
        { label: 'Once', value: 'Skipped on later language picks' },
      ],
      status: 'working',
    },
    {
      number: '04',
      id: 'scanner',
      category: 'Capture',
      title: 'Scanner',
      description: 'Full-screen camera with gallery, flash, framing prompts, and offline presets.',
      userDoes: 'Frames a paper, picks gallery, or chooses a demo preset.',
      appDoes: 'Speaks scan prompt; hands image/path to analysis pipeline.',
      tech: 'camera_scanner_view.dart · camera · image_picker · PresetService',
      screenshot: '/assets/steps/step-04-scanner.png',
      screenshotNote: 'App screenshot · scanner',
      facts: [
        { label: 'Hardware', value: 'Camera optional if using presets' },
        { label: 'Presets', value: 'Loan, deed, labor, medical (+ forms in code)' },
        { label: 'Mode chooser', value: 'Skipped (kFormGuideEnabled=false)' },
        { label: 'Flash', value: 'Where device supports it' },
      ],
      status: 'working',
    },
    {
      number: '05',
      id: 'loading',
      category: 'Process',
      title: 'Loading',
      description: 'Animated logo and analyzing copy while OCR + rules run.',
      userDoes: 'Waits; can hear processing prompt.',
      appDoes: 'Runs DocumentRepository.analyzeFromImagePath; severity haptics.',
      tech: 'main.dart loading view · OcrService · RuleEngine',
      screenshot: '/assets/steps/step-05-loading.png',
      screenshotNote: 'App screenshot · loading',
      facts: [
        { label: 'OCR', value: 'On-device ML Kit' },
        { label: 'Rules', value: 'Deterministic keyword engine' },
        { label: 'Motion', value: 'Pulsing / orbiting logo' },
        { label: 'Fallback', value: 'Unclear on analysis error' },
      ],
      status: 'working',
    },
    {
      number: '06',
      id: 'results',
      category: 'Output',
      title: 'Results',
      description: 'Security badge, spoken narrative, tap-to-replay warnings, text readers.',
      userDoes: 'Listens, taps warnings to replay, may hear OCR text word/sentence-wise.',
      appDoes: 'Shows DocumentAnalyzerView with localized warnings and TTS.',
      tech: 'document_analyzer_view.dart · SecurityBadge · InteractiveWordReader',
      screenshot: '/assets/steps/step-06-results.png',
      screenshotNote: 'App screenshot · results',
      facts: [
        { label: 'Colors', value: 'Green / amber / red / info' },
        { label: 'Not advice', value: 'Rule-based, not a lawyer' },
        { label: 'Listen again', value: 'Guided screens + AppBar' },
        { label: 'Form walkthrough', value: 'Off in this build flag' },
      ],
      status: 'working',
    },
  ] satisfies WorkflowStep[],
} as const
