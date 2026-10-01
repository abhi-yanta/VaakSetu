/** Exact list from mobile/lib/domain/models/language.dart */
export const languagesContent = {
  eyebrow: 'Language support',
  headlineBefore: 'Twelve Indian languages with',
  headlineAccent: 'their own scripts.',
  intro:
    'UI strings, spoken prompts, and analyzer copy are localized. Interaction is tap + TTS — there is no speech-to-text pipeline today.',
  languages: [
    { code: 'hi', native: 'हिन्दी', english: 'Hindi', script: 'अ', tts: 'hi-IN' },
    { code: 'ta', native: 'தமிழ்', english: 'Tamil', script: 'அ', tts: 'ta-IN' },
    { code: 'te', native: 'తెలుగు', english: 'Telugu', script: 'అ', tts: 'te-IN' },
    { code: 'mr', native: 'मराठी', english: 'Marathi', script: 'म', tts: 'mr-IN' },
    { code: 'bn', native: 'বাংলা', english: 'Bengali', script: 'অ', tts: 'bn-IN' },
    { code: 'gu', native: 'ગુજરાતી', english: 'Gujarati', script: 'અ', tts: 'gu-IN' },
    { code: 'kn', native: 'ಕನ್ನಡ', english: 'Kannada', script: 'ಅ', tts: 'kn-IN' },
    { code: 'ml', native: 'മലയാളം', english: 'Malayalam', script: 'അ', tts: 'ml-IN' },
    { code: 'or', native: 'ଓଡ଼ିଆ', english: 'Odia', script: 'ଅ', tts: 'or-IN' },
    { code: 'pa', native: 'ਪੰਜਾਬੀ', english: 'Punjabi', script: 'ਅ', tts: 'pa-IN' },
    { code: 'as', native: 'অসমীয়া', english: 'Assamese', script: 'ক', tts: 'as-IN' },
    { code: 'ur', native: 'اردو', english: 'Urdu', script: 'ا', tts: 'ur-IN' },
  ],
  facts: [
    { label: 'Text UI', value: 'Localized via LocalizedContent' },
    { label: 'Voice', value: 'Device TTS + optional Bhashini / HF' },
    { label: 'Script badges', value: 'Iconic script characters in grid' },
    { label: 'STT', value: 'Not implemented' },
  ],
} as const
