export const problemContent = {
  eyebrow: 'The problem',
  headlineBefore: 'Legal and financial papers are',
  headlineAccent: 'invisible without literacy.',
  intro:
    'In rural and semi-urban India, complex English or legalese on stamp paper is effectively unreadable for many people who still must decide whether to sign.',
  points: [
    {
      title: 'Predatory loans',
      body: 'High interest (often framed as “per month”), blank-cheque patterns, and land as collateral for small cash — harms described in product docs as common risks.',
    },
    {
      title: 'Misleading land papers',
      body: 'Documents presented as “loan receipts” that are actually sale deeds or irrevocable powers of attorney.',
    },
    {
      title: 'Exploitative labor & medical waivers',
      body: 'Bonded-labor style clauses, unpaid overtime, resignation penalties, and emergency signatures that wipe hospital liability.',
    },
    {
      title: 'Form anxiety',
      body: 'Even when a form is “safe,” people cannot tell what each blank means — Form Field Guide exists in code but is currently off in the shipped navigation flag.',
    },
  ],
  note: 'No invented literacy percentages or user counts. Problem framing follows docs/VaakSetu_Overview.md and README.md.',
} as const
