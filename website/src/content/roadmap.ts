export const roadmapContent = {
  eyebrow: 'Roadmap',
  headlineBefore: 'What the code shows as',
  headlineAccent: 'done, in progress, planned.',
  intro:
    'Statuses inferred from README, overview §16–17, main.dart flags, and explicit gaps (STT, Form Guide off, iOS not focus).',
  columns: [
    {
      title: 'Done',
      items: [
        'Flutter document safety path: Welcome → Language → Tour → Scanner → Loading → Results',
        '12-language UI + TTS prompts',
        'ML Kit on-device OCR + RuleEngine categories/severities',
        'Camera / gallery / offline presets',
        'Device TTS + optional Bhashini / HF prefetch layers',
        'Listen-again, haptics, cream vernacular UX',
        'Mascot feature tour (forms page omitted while Form Guide off)',
      ],
    },
    {
      title: 'In progress',
      items: [
        'OCR resilience on stamp papers / multi-script yields',
        'Rule coverage and synthetic benchmark refinement (dataset/)',
        'TTS quality path when optional keys are present',
        'Rural UX polish (captions, motion, replay)',
      ],
    },
    {
      title: 'Planned / gated',
      items: [
        'Re-enable Form Field Guide + mode chooser (kFormGuideEnabled currently false)',
        'Layout-aware form blank detection (beyond heuristics)',
        'Speech-to-text / voice commands (explicitly not built)',
        'Stronger web ↔ mobile feature parity for CSC kiosk path',
        'iOS packaging not the current focus',
      ],
    },
  ],
} as const
