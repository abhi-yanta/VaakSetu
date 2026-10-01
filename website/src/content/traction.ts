/** No awards/media/traction numbers found in repo — all placeholders. */
export const tractionContent = {
  eyebrow: 'Traction & recognition',
  headlineBefore: 'Only evidenced milestones',
  headlineAccent: 'belong here.',
  intro:
    'Repository search found no named hackathon wins, press logos, user counts, or revenue figures. Cards below are placeholders until real artifacts are supplied.',
  cards: [
    {
      category: 'PLACEHOLDER',
      title: 'PLACEHOLDER: Recognition moment',
      caption: 'PLACEHOLDER: photo / certificate caption',
      photo: '/assets/traction/placeholder-1.svg',
      facts: [
        { label: 'Result', value: 'PLACEHOLDER' },
        { label: 'Year', value: 'PLACEHOLDER' },
        { label: 'Venue', value: 'PLACEHOLDER' },
        { label: 'Evidence', value: 'Not in repo' },
      ],
    },
    {
      category: 'PLACEHOLDER',
      title: 'PLACEHOLDER: Pilot / field note',
      caption: 'PLACEHOLDER: field photo caption',
      photo: '/assets/traction/placeholder-2.svg',
      facts: [
        { label: 'Users', value: 'PLACEHOLDER' },
        { label: 'Docs scanned', value: 'PLACEHOLDER' },
        { label: 'Location', value: 'PLACEHOLDER' },
        { label: 'Evidence', value: 'Not in repo' },
      ],
    },
  ],
  /** No real counters — do not animate fake numbers. */
  counters: [] as { label: string; value: number; suffix?: string; note: string }[],
} as const
