import type { StatusKind } from './hero'

export const documentsContent = {
  eyebrow: 'Document types',
  headlineBefore: 'Categories the rule engine',
  headlineAccent: 'actually classifies.',
  intro:
    'Document safety mode targets loan, deed, job, and medical papers, plus unrecognized / unclear gates. Form samples exist as presets but Form Guide navigation is off.',
  types: [
    {
      category: 'Loan',
      title: 'Loan / microfinance papers',
      example: 'Demo preset: “36% High-Interest Loan” with land-seizure clause.',
      readAloud: 'Category, severity, and warning lines (e.g. high interest, collateral).',
      limitations: 'Keyword/rule based — not legal advice; OCR depends on lighting and fonts.',
      status: 'working' as StatusKind,
      facts: [
        { label: 'Engine keys', value: 'loanKeywords + interest rules' },
        { label: 'Example risk', value: '~24%+ APR style patterns' },
        { label: 'Demo', value: 'loan_fraud preset' },
        { label: 'Status', value: 'Working in document mode' },
      ],
    },
    {
      category: 'Deed',
      title: 'Land / sale deeds & stamp papers',
      example: 'Demo preset: standard land sale deed with mutual consent.',
      readAloud: 'Category + severity; highlights risky clause matches when present.',
      limitations: 'Stamp fonts and multi-script papers remain OCR-hard.',
      status: 'working' as StatusKind,
      facts: [
        { label: 'Markers', value: 'sale deed, khasra, e-stamp…' },
        { label: 'OCR', value: 'Devanagari + Latin + fallback' },
        { label: 'Demo', value: 'land_deed_safe preset' },
        { label: 'Status', value: 'Working in document mode' },
      ],
    },
    {
      category: 'Job',
      title: 'Labor / employment contracts',
      example: 'Demo preset: exploitative labor contract with bond penalty.',
      readAloud: 'Warnings for bonded-labor style / unpaid overtime patterns.',
      limitations: 'Deterministic phrases only — misses novel wording.',
      status: 'working' as StatusKind,
      facts: [
        { label: 'Demo', value: 'labor_bond preset' },
        { label: 'Severity', value: 'Often danger when matched' },
        { label: 'Not LLM', value: 'No generative legal opinion' },
        { label: 'Status', value: 'Working in document mode' },
      ],
    },
    {
      category: 'Medical',
      title: 'Hospital consent / liability forms',
      example: 'Demo preset: broad liability waiver on surgery consent.',
      readAloud: 'Caution on blanket medical waiver language.',
      limitations: 'Does not replace clinical or legal counsel.',
      status: 'working' as StatusKind,
      facts: [
        { label: 'Demo', value: 'medical_waiver preset' },
        { label: 'Category', value: 'DocumentCategory.medical' },
        { label: 'Advice', value: 'Not medical/legal advice' },
        { label: 'Status', value: 'Working in document mode' },
      ],
    },
    {
      category: 'Forms',
      title: 'KYC / government-style forms',
      example: 'Presets: kisan welfare, scholarship, ration card, bank KYC, job application.',
      readAloud: 'Form Field Guide would speak field-by-field help when enabled.',
      limitations: 'kFormGuideEnabled=false — mode chooser and Form Guide UI path off.',
      status: 'disabled' as StatusKind,
      facts: [
        { label: 'Dictionary', value: '~22 field keys in Dart' },
        { label: 'Matching', value: 'Heuristic label match' },
        { label: 'Layout', value: 'Not a trained DocAI model' },
        { label: 'Flag', value: 'kFormGuideEnabled = false' },
      ],
    },
  ],
} as const
