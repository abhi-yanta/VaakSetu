export const techContent = {
  eyebrow: 'Under the hood',
  headlineBefore: 'Offline-first OCR and rules;',
  headlineAccent: 'optional cloud voices.',
  intro:
    'Stack facts from mobile/pubspec.yaml, AndroidManifest.xml, ocr_service.dart, tts_service.dart, and rule_engine.dart.',
  layers: [
    {
      category: 'App',
      title: 'Flutter 3.x / Dart',
      description: 'Flagship Android app vaaksetu_mobile v1.0.0+1 with Provider-style ChangeNotifier state and shared_preferences.',
      facts: [
        { label: 'Package', value: 'vaaksetu_mobile' },
        { label: 'Min SDK', value: 'Android 21' },
        { label: 'State', value: 'ChangeNotifier / provider' },
        { label: 'UI theme', value: 'Cream #F7F3EB · saffron · teal' },
      ],
    },
    {
      category: 'OCR',
      title: 'Google ML Kit Text Recognition',
      description: 'On-device OCR. Devanagari + Latin in parallel; Chinese script pass if yield is low (~80 chars). Models bundled via ML Kit DEPENDENCIES meta-data.',
      facts: [
        { label: 'Dependency', value: 'google_mlkit_text_recognition' },
        { label: 'Bundled', value: 'text_latin, text_devanagari, text_chinese' },
        { label: 'Network for OCR', value: 'Not required' },
        { label: 'Privacy', value: 'Document analysis on phone' },
      ],
    },
    {
      category: 'Speech',
      title: 'TTS cascade (hot path = device)',
      description:
        'Speak path starts device TTS immediately. Optional Bhashini/ULCA and Hugging Face AI4Bharat voices prefetch for later cache hits. Without keys, device TTS still works.',
      facts: [
        { label: 'Hot path', value: 'flutter_tts (device)' },
        { label: 'Layer 1 (optional)', value: 'Bhashini / ULCA' },
        { label: 'Layer 2 (optional)', value: 'HF ai4bharat/indic-parler-tts' },
        { label: 'Playback helper', value: 'audioplayers' },
      ],
    },
    {
      category: 'Rules',
      title: 'Deterministic RuleEngine',
      description: 'Keyword and pattern checks for category, severity, and clause highlights. Explicitly not an LLM lawyer.',
      facts: [
        { label: 'File', value: 'domain/rules/rule_engine.dart' },
        { label: 'Benchmark hub', value: 'dataset/synthetic (~88 cases)' },
        { label: 'Haptics', value: 'vibration permission' },
        { label: 'STT', value: 'None' },
      ],
    },
  ],
  permissions: [
    { name: 'CAMERA', why: 'Document scanning' },
    { name: 'VIBRATE', why: 'Accessibility haptics' },
    { name: 'READ_MEDIA_IMAGES / storage (≤32)', why: 'Gallery document photos' },
    { name: 'INTERNET', why: 'Optional Bhashini / Hugging Face TTS only' },
  ],
  privacyNote:
    'Core OCR + rule analysis run on-device. Internet is declared for optional online TTS; without keys the app falls back to device TTS. Camera audio is disabled; there is no STT.',
} as const
