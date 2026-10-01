/**
 * Single source of truth for the landing walkthrough.
 *
 * Derived ONLY from Flutter navigation in `mobile/lib/main.dart`
 * (AppView + handlers) with `kFormGuideEnabled = false`.
 *
 * First-run order:
 * welcome → language → featureTour → scanner → loading → analyzer
 *
 * Form Guide / mode chooser are disabled — not listed as steps.
 * No STT / voice-command claims.
 */

export interface StepBullet {
  title: string
  body: string
}

export interface WorkflowStep {
  id: string
  number: string
  navLabel: string
  title: string
  body: string
  /** Screen texture / placeholder under public/ */
  texture: string
  textureAlt: string
  bullets: StepBullet[]
  /** Flutter sources that define this step */
  sources: string[]
}

/** From Language.supportedLanguages in mobile/lib/domain/models/language.dart */
export const LANGUAGES = [
  { code: 'hi', native: 'हिन्दी', english: 'Hindi', script: 'अ' },
  { code: 'ta', native: 'தமிழ்', english: 'Tamil', script: 'அ' },
  { code: 'te', native: 'తెలుగు', english: 'Telugu', script: 'అ' },
  { code: 'mr', native: 'मराठी', english: 'Marathi', script: 'म' },
  { code: 'bn', native: 'বাংলা', english: 'Bengali', script: 'অ' },
  { code: 'gu', native: 'ગુજરાતી', english: 'Gujarati', script: 'અ' },
  { code: 'kn', native: 'ಕನ್ನಡ', english: 'Kannada', script: 'ಅ' },
  { code: 'ml', native: 'മലയാളം', english: 'Malayalam', script: 'അ' },
  { code: 'or', native: 'ଓଡ଼ିଆ', english: 'Odia', script: 'ଅ' },
  { code: 'pa', native: 'ਪੰਜਾਬੀ', english: 'Punjabi', script: 'ਅ' },
  { code: 'as', native: 'অসমীয়া', english: 'Assamese', script: 'ক' },
  { code: 'ur', native: 'اردو', english: 'Urdu', script: 'ا' },
] as const

export const STEPS: WorkflowStep[] = [
  {
    id: 'welcome',
    number: '01',
    navLabel: 'Welcome',
    title: 'Welcome splash',
    body: 'Brand mark, वाक् सेतु / “The Voice Bridge,” and a large tactile start: यहाँ दबाएं / TAP HERE.',
    texture: '/assets/steps/step-01-welcome.png',
    textureAlt: 'Welcome screen placeholder — swap with WelcomeView capture',
    bullets: [
      {
        title: 'Animated brand mark',
        body: 'Option 4 V–S bridge mark via AnimatedLogo on cream surfaces.',
      },
      {
        title: 'Big start control',
        body: 'TactileButton opens the language picker (no STT).',
      },
      {
        title: 'Hindi copy first',
        body: 'Welcome copy is Hindi-first for rural reachability.',
      },
    ],
    sources: [
      'mobile/lib/main.dart (AppView.welcome)',
      'mobile/lib/ui/features/language_selection/welcome_view.dart',
      'mobile/lib/ui/core/animated_logo.dart',
    ],
  },
  {
    id: 'language',
    number: '02',
    navLabel: 'Language',
    title: 'Choose your language',
    body: 'Grid of 12 Indian languages with native names. Hindi welcome TTS plays; “फिर से सुनो” replays it.',
    texture: '/assets/steps/step-02-language.png',
    textureAlt: 'Language grid placeholder — swap with LanguageSelectorView capture',
    bullets: [
      {
        title: '12 Indic languages',
        body: 'From Language.supportedLanguages — native script labels.',
      },
      {
        title: 'Spoken welcome',
        body: 'TTS speaks the Hindi welcome prompt while you choose.',
      },
      {
        title: 'Listen again',
        body: 'फिर से सुनो / AppBar speaker replays the current prompt.',
      },
    ],
    sources: [
      'mobile/lib/main.dart (_onStart → AppView.language)',
      'mobile/lib/ui/features/language_selection/language_selector_view.dart',
      'mobile/lib/domain/models/language.dart',
    ],
  },
  {
    id: 'tour',
    number: '03',
    navLabel: 'Tour',
    title: 'Feature tour',
    body: 'First-time mascot pages (scan, safety, 12 languages) spoken in the chosen language. Finishing opens the scanner.',
    texture: '/assets/steps/step-03-feature-tour.png',
    textureAlt: 'Feature tour placeholder — swap with CharacterWelcomeView capture',
    bullets: [
      {
        title: 'Camera scan page',
        body: 'Photo the document — VaakSetu reads the text aloud.',
      },
      {
        title: 'Safety check page',
        body: 'Fraud / danger signals trigger immediate warnings.',
      },
      {
        title: '12 languages page',
        body: 'Everything after this speaks and shows in your language. Form Guide tour omitted while disabled.',
      },
    ],
    sources: [
      'mobile/lib/main.dart (_onLanguageSelected → AppView.featureTour)',
      'mobile/lib/ui/features/language_selection/character_welcome_view.dart',
      'mobile/lib/domain/models/localized_content.dart (tour_* keys)',
    ],
  },
  {
    id: 'scanner',
    number: '04',
    navLabel: 'Scanner',
    title: 'Document camera scanner',
    body: 'Full-screen live camera with shutter, gallery, flash, and a spoken framing prompt. Offline demo presets available.',
    texture: '/assets/steps/step-04-scanner.png',
    textureAlt: 'Scanner placeholder — swap with CameraScannerView capture',
    bullets: [
      {
        title: 'Live camera + gallery',
        body: 'Capture or pick an image; captions stay in the footer zone.',
      },
      {
        title: 'Spoken framing prompt',
        body: 'scan_prompt TTS guides framing in the selected language.',
      },
      {
        title: 'Direct after tour',
        body: 'With kFormGuideEnabled=false, no mode chooser — tour ends here.',
      },
    ],
    sources: [
      'mobile/lib/main.dart (_openDocumentScanner, kFormGuideEnabled)',
      'mobile/lib/ui/features/document_scanner/camera_scanner_view.dart',
    ],
  },
  {
    id: 'loading',
    number: '05',
    navLabel: 'Analyze',
    title: 'OCR & rule analysis',
    body: 'Analyzing / please-wait copy with the pulsing logo while on-device OCR and the document rule engine run.',
    texture: '/assets/steps/step-05-loading.png',
    textureAlt: 'Loading placeholder — swap with analyzing screen capture',
    bullets: [
      {
        title: 'On-device OCR',
        body: 'DocumentRepository.analyzeFromImagePath runs locally.',
      },
      {
        title: 'Rule severity',
        body: 'safe / warning / danger / unknown from the rule engine.',
      },
      {
        title: 'Processing TTS',
        body: 'processing prompt speaks while the AnimatedLogo pulses.',
      },
    ],
    sources: [
      'mobile/lib/main.dart (_processImage → AppView.loading)',
      'mobile/lib/data/repositories/document_repository.dart',
      'mobile/lib/ui/core/animated_logo.dart',
    ],
  },
  {
    id: 'results',
    number: '06',
    navLabel: 'Results',
    title: 'Spoken safety results',
    body: 'Category + severity badge, warning list, wave visualizer, and result TTS with captions and listen-again.',
    texture: '/assets/steps/step-06-results.png',
    textureAlt: 'Results placeholder — swap with DocumentAnalyzerView capture',
    bullets: [
      {
        title: 'Result narrative TTS',
        body: 'LocalizedContent.buildResultSpeech announces the overview.',
      },
      {
        title: 'Captions footer',
        body: 'SpeakingCaptionFooter shows live captions while audio plays.',
      },
      {
        title: 'Listen again',
        body: 'AppBar speaker + फिर से सुनो replay the result narrative.',
      },
    ],
    sources: [
      'mobile/lib/main.dart (AppView.analyzer)',
      'mobile/lib/ui/features/document_analyzer/document_analyzer_view.dart',
      'mobile/lib/ui/core/speaking_caption_footer.dart',
      'mobile/lib/ui/core/listen_again_button.dart',
      'mobile/lib/data/services/tts_service.dart',
    ],
  },
]

export const hero = {
  name: 'VaakSetu',
  nameHi: 'वाक् सेतु',
  tagline: 'Every document, in your language.',
  subtitle:
    'Audio-first document assistant — scan a paper, hear a clear safety summary across 12 Indian languages.',
}

export const FEATURES = [
  {
    title: '12 Indian languages',
    body: 'Hindi, Tamil, Telugu, Marathi, Bengali, Gujarati, Kannada, Malayalam, Odia, Punjabi, Assamese, Urdu — Language.supportedLanguages.',
  },
  {
    title: 'On-device OCR + rules',
    body: 'Camera or gallery → OCR → rule severity (safe / warning / danger / unknown). No invented “lawyer AI.”',
  },
  {
    title: 'TTS, captions, listen again',
    body: 'Spoken prompts per screen, live caption footer, AppBar mute/replay, and फिर से सुनो on guided views.',
  },
  {
    title: 'Who it helps',
    body: 'Rural / low-literacy adults, workers and farmers reading loan or land papers, and helpers guiding a relative.',
  },
]

export const finaleCaveat =
  'Form Field Guide and the mode chooser (“क्या करना है”) exist in code but are disabled (kFormGuideEnabled = false). After the feature tour, the app opens the legal document scanner directly. No STT.'
