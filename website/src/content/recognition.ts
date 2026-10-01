export type LogoPlaceholder = {
  id: string
  label: string
  category: string
  src: string
}

/** All logos are placeholders until real marks are supplied. */
export const recognitionLogos: LogoPlaceholder[] = [
  {
    id: 'hackathon',
    label: 'PLACEHOLDER: Hackathon / program logo',
    category: 'Recognition',
    src: '/assets/logos/hackathon.svg',
  },
  {
    id: 'college',
    label: 'PLACEHOLDER: College / institution logo',
    category: 'Institution',
    src: '/assets/logos/college.svg',
  },
  {
    id: 'flutter',
    label: 'Flutter',
    category: 'Tools',
    src: '/assets/logos/flutter.svg',
  },
  {
    id: 'mlkit',
    label: 'Google ML Kit',
    category: 'Tools',
    src: '/assets/logos/mlkit.svg',
  },
  {
    id: 'bhashini',
    label: 'Bhashini / ULCA (optional TTS)',
    category: 'Tools',
    src: '/assets/logos/bhashini.svg',
  },
  {
    id: 'partner',
    label: 'PLACEHOLDER: Partner / NGO logo',
    category: 'Partners',
    src: '/assets/logos/partner.svg',
  },
]

export const recognitionContent = {
  eyebrow: 'Recognition strip',
  headlineBefore: 'Programs, tools, and partners we',
  headlineAccent: 'intend to show here.',
  intro:
    'Replace placeholder marks with evidenced logos only. Tool names below reflect real dependencies in the Flutter app.',
} as const
