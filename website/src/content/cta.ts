export const ctaContent = {
  eyebrow: 'Next step',
  headlineBefore: 'Try the Voice Bridge,',
  headlineAccent: 'or talk to the team.',
  intro:
    'Download points at the GitHub repository release/APK path until a store listing exists. Early-access form is front-end only until a backend is wired.',
  primary: 'Download the app',
  secondary: 'Get early access',
  downloadHref: 'https://github.com/abhi-yanta/VaakSetu',
  form: {
    title: 'Get early access / Request demo',
    fields: [
      { name: 'name', label: 'Name', type: 'text', required: true },
      { name: 'org', label: 'Organisation', type: 'text', required: true },
      { name: 'role', label: 'Role', type: 'text', required: true },
      {
        name: 'useCase',
        label: 'Use case',
        type: 'textarea',
        required: true,
      },
    ] as const,
    consent:
      'I agree to be contacted about VaakSetu demos. PLACEHOLDER: privacy policy URL.',
    submitLabel: 'Submit request',
    successTitle: 'Request captured locally',
    successBody:
      'PLACEHOLDER: backend submit endpoint — this build only validates and shows success in the browser.',
  },
} as const

export const footerContent = {
  brand: 'VaakSetu',
  tagline: 'The Voice Bridge — audio-first document safety.',
  explore: [
    { label: 'Workflow', href: '#workflow' },
    { label: 'Languages', href: '#languages' },
    { label: 'Under the hood', href: '#tech' },
    { label: 'Evidence', href: '#evidence' },
    { label: 'FAQ', href: '#faq' },
  ],
  company: [
    { label: 'Roadmap', href: '#roadmap' },
    { label: 'Team', href: '#team' },
    { label: 'GitHub', href: 'https://github.com/abhi-yanta/VaakSetu' },
  ],
  connect: [
    { label: 'PLACEHOLDER: Email', href: '#' },
    { label: 'PLACEHOLDER: Twitter / X', href: '#' },
    { label: 'PLACEHOLDER: LinkedIn page', href: '#' },
  ],
  location: 'PLACEHOLDER: City / region',
  note: 'Second company landing (website/). First 3D/workflow landing remains at landing/.',
} as const
