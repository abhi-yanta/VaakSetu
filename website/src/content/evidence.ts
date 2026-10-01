export const evidenceContent = {
  eyebrow: 'Evidence before promises',
  headlineBefore: 'Test. Observe. Refine.',
  headlineAccent: 'Document.',
  intro:
    'VaakSetu is a development-stage accessibility product. Claims about accuracy, legal outcomes, or scale require documented validation — not ambition alone.',
  canDo: [
    'On-device OCR with ML Kit for captured or preset documents',
    'Rule-based category/severity and spoken warnings in 12 languages',
    'Offline demos via built-in presets without printed paper',
    'Device TTS always; optional higher-quality cloud voices with keys',
  ],
  cannotDo: [
    'Not legal advice and not a substitute for a lawyer',
    'Not an LLM “read everything” analyst — deterministic keywords/rules',
    'No speech-to-text / voice-command pipeline',
    'OCR quality depends on lighting, stamp fonts, and script coverage',
    'Form blank placement is heuristic; Form Guide UI currently off',
  ],
  questions: [
    {
      number: '01',
      title: 'OCR reliability across real stamp papers',
      body: 'How often does multi-script OCR yield enough text under village lighting and worn stamps?',
    },
    {
      number: '02',
      title: 'False reassurance vs false alarm',
      body: 'Do unrecognized/unclear gates prevent green “safe” badges on ambiguous notebooks?',
    },
    {
      number: '03',
      title: 'Rule coverage vs novel wording',
      body: 'Which predatory clauses still evade current keyword lists across languages?',
    },
    {
      number: '04',
      title: 'TTS intelligibility offline',
      body: 'Is device TTS clear enough for older listeners when Bhashini/HF keys are absent?',
    },
    {
      number: '05',
      title: 'Form Guide readiness',
      body: 'When should kFormGuideEnabled flip on — after layout heuristics meet what bar?',
    },
  ],
} as const
