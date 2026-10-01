import type { StatusKind } from './hero'

export type PipelineCard = {
  number: string
  category: string
  title: string
  description: string
  facts: { label: string; value: string }[]
  status: StatusKind
}

export const fitContent = {
  eyebrow: 'Where VaakSetu fits',
  headlineBefore: 'One practical path from',
  headlineAccent: 'camera to spoken caution.',
  intro:
    'The live product path is Input → Process → Output. Form Field Guide and the mode chooser are present in code but disabled via kFormGuideEnabled = false.',
  cards: [
    {
      number: '01',
      category: 'Input',
      title: 'Camera, gallery, or demo preset',
      description:
        'User captures or picks a document image, or selects an offline demo preset so demos work without printed paper.',
      facts: [
        { label: 'Sources', value: 'camera · image_picker · presets' },
        { label: 'Permissions', value: 'CAMERA, photos, VIBRATE' },
        { label: 'Offline demos', value: 'Loan / deed / job / medical presets' },
        { label: 'Form presets', value: 'In code; Form Guide UI currently off' },
      ],
      status: 'working',
    },
    {
      number: '02',
      category: 'Process',
      title: 'On-device OCR + rule engine',
      description:
        'Google ML Kit extracts text on the phone. A deterministic Dart rule engine classifies category and severity — not an LLM lawyer.',
      facts: [
        { label: 'OCR', value: 'google_mlkit_text_recognition' },
        { label: 'Scripts tried', value: 'Devanagari + Latin (+ Chinese fallback)' },
        { label: 'Engine', value: 'RuleEngine.analyze' },
        { label: 'Privacy', value: 'Analysis stays on-device' },
      ],
      status: 'working',
    },
    {
      number: '03',
      category: 'Output',
      title: 'Spoken safety summary',
      description:
        'Color severity badge, warning lines, haptics, and TTS narration in the selected language — with listen-again controls.',
      facts: [
        { label: 'Severities', value: 'safe · warning · danger · unknown' },
        { label: 'Categories', value: 'loan · deed · job · medical · unclear' },
        { label: 'Speech', value: 'Device TTS first; optional cloud voices' },
        { label: 'Not included', value: 'No speech-to-text / voice commands' },
      ],
      status: 'working',
    },
  ] satisfies PipelineCard[],
} as const
