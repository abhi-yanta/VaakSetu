export const audienceContent = {
  eyebrow: 'Who it is for',
  headlineBefore: 'Built for people who need',
  headlineAccent: 'spoken caution — not jargon.',
  intro:
    'Audience list follows docs/VaakSetu_Overview.md. Institutional CSC/kiosk path exists as a secondary web stack; treat Flutter as the source of truth.',
  groups: [
    {
      number: '01',
      title: 'Rural / low-literacy adults',
      body: 'Hear category and danger cues without needing to read dense stamp paper.',
      note: 'Primary intended user from product docs.',
    },
    {
      number: '02',
      title: 'Semi-literate workers & farmers',
      body: 'Spot red-flag loan, land, and labor clauses before signing.',
      note: 'Supported by document safety mode + presets.',
    },
    {
      number: '03',
      title: 'Families helping a relative',
      body: 'Guide someone through a paper with listen-again and large targets.',
      note: 'Form field walkthrough is in code but currently disabled.',
    },
    {
      number: '04',
      title: 'CSC / village helpers',
      body: 'Assist others; web/kiosk path under client/ + server/ for shared-laptop demos.',
      note: 'PLACEHOLDER: do not claim formal CSC partnerships without evidence.',
    },
    {
      number: '05',
      title: 'NGOs & legal-aid volunteers',
      body: 'Demo offline presets to show spoken warnings without printed originals.',
      note: 'PLACEHOLDER: named NGO partners not found in repo.',
    },
    {
      number: '06',
      title: 'Banks / KYC desks',
      body: 'Bank KYC-style form presets exist for Form Guide experiments.',
      note: 'PLACEHOLDER: no bank deployment claims in repo — Form Guide currently off.',
    },
  ],
} as const
