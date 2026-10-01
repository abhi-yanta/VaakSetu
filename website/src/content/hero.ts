export type StatusKind = 'working' | 'validation' | 'planned' | 'disabled'

export const statusLabels: Record<StatusKind, string> = {
  working: 'Working in app',
  validation: 'Under validation',
  planned: 'Planned',
  disabled: 'Off in current build',
}

export const navLinks = [
  { href: '#problem', label: 'Problem' },
  { href: '#workflow', label: 'Workflow' },
  { href: '#languages', label: 'Languages' },
  { href: '#evidence', label: 'Evidence' },
  { href: '#roadmap', label: 'Roadmap' },
  { href: '#faq', label: 'FAQ' },
] as const

export const heroContent = {
  eyebrow: 'VaakSetu · वाक् सेतु',
  headlineBefore: 'Hear the paper before you',
  headlineAccent: 'sign it.',
  description:
    'Audio-first Android app for low-literacy and rural users: point a phone camera at a legal paper, run on-device OCR, and hear a spoken safety summary in one of 12 Indian languages.',
  primaryCta: 'Download the app',
  secondaryCta: 'See how it works →',
  /** No hackathon/finalist evidence found in repo — keep placeholder chip. */
  statusChip: 'PLACEHOLDER: Building / Hackathon finalist (replace only with evidenced status)',
  phoneCaption: 'Concept UI · sample values',
  versionNote: 'Primary product: Flutter app in mobile/ (v1.0.0)',
  sources: ['README.md', 'mobile/lib/main.dart', 'docs/VaakSetu_Overview.md', 'mobile/pubspec.yaml'],
} as const
