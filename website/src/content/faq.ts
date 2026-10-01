export const faqContent = {
  eyebrow: 'FAQ',
  headlineBefore: 'Straight answers from',
  headlineAccent: 'the codebase.',
  intro: 'Ten questions grounded in README, overview, and mobile/lib — not marketing invention.',
  items: [
    {
      q: 'What does VaakSetu do?',
      a: 'It is an audio-first Android app: scan or pick a legal paper, run on-device OCR, classify with a rule engine, and speak a safety summary in the user’s language.',
    },
    {
      q: 'Is Form Field Guide available right now?',
      a: 'Form Guide code exists, but kFormGuideEnabled is false in main.dart. After the feature tour the app opens the document scanner directly — no mode chooser.',
    },
    {
      q: 'Does analysis leave my phone?',
      a: 'Core OCR and rule analysis run on-device with ML Kit. Internet permission is for optional online TTS (Bhashini / Hugging Face). Without keys, speech uses device TTS.',
    },
    {
      q: 'Is this legal advice?',
      a: 'No. Classification is keyword/rule-based and not a substitute for a lawyer. README lists this under honest limits.',
    },
    {
      q: 'Which languages are supported?',
      a: 'Twelve: Hindi, Tamil, Telugu, Marathi, Bengali, Gujarati, Kannada, Malayalam, Odia, Punjabi, Assamese, and Urdu — matching Language.supportedLanguages.',
    },
    {
      q: 'Can I talk to the app with my voice?',
      a: 'No. There is no speech-to-text / voice-command pipeline. Interaction is tap + spoken playback.',
    },
    {
      q: 'What if I have no printed document for a demo?',
      a: 'Use offline demo presets on the scanner screen (loan, deed, labor, medical, and form samples in code).',
    },
    {
      q: 'What permissions does Android require?',
      a: 'CAMERA, VIBRATE, photo/storage read for gallery, and INTERNET for optional cloud TTS — see AndroidManifest.xml.',
    },
    {
      q: 'What document categories exist?',
      a: 'loan, deed, job, medical, unrecognized, and unclear — with severities safe, warning, danger, and unknown.',
    },
    {
      q: 'Where is the primary product vs older web demos?',
      a: 'Flutter app in mobile/ is the flagship. client/ + server/ are a secondary kiosk/web path with lagging feature parity.',
    },
  ],
} as const
