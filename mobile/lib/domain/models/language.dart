/// Supported Indic languages with native names, script codes, and TTS locales.
class Language {
  final String code;
  final String nativeName;
  final String englishLabel;
  final String flagEmoji;
  final String ttsLocale;

  const Language({
    required this.code,
    required this.nativeName,
    required this.englishLabel,
    required this.flagEmoji,
    required this.ttsLocale,
  });

  static const List<Language> supportedLanguages = [
    Language(
      code: 'hi',
      nativeName: 'हिन्दी',
      englishLabel: 'Hindi',
      flagEmoji: '🇮🇳',
      ttsLocale: 'hi-IN',
    ),
    Language(
      code: 'ta',
      nativeName: 'தமிழ்',
      englishLabel: 'Tamil',
      flagEmoji: '🇮🇳',
      ttsLocale: 'ta-IN',
    ),
    Language(
      code: 'te',
      nativeName: 'తెలుగు',
      englishLabel: 'Telugu',
      flagEmoji: '🇮🇳',
      ttsLocale: 'te-IN',
    ),
    Language(
      code: 'mr',
      nativeName: 'मराठी',
      englishLabel: 'Marathi',
      flagEmoji: '🇮🇳',
      ttsLocale: 'mr-IN',
    ),
    Language(
      code: 'bn',
      nativeName: 'বাংলা',
      englishLabel: 'Bengali',
      flagEmoji: '🇮🇳',
      ttsLocale: 'bn-IN',
    ),
    Language(
      code: 'gu',
      nativeName: 'ગુજરાતી',
      englishLabel: 'Gujarati',
      flagEmoji: '🇮🇳',
      ttsLocale: 'gu-IN',
    ),
    Language(
      code: 'kn',
      nativeName: 'ಕನ್ನಡ',
      englishLabel: 'Kannada',
      flagEmoji: '🇮🇳',
      ttsLocale: 'kn-IN',
    ),
    Language(
      code: 'ml',
      nativeName: 'മലയാളം',
      englishLabel: 'Malayalam',
      flagEmoji: '🇮🇳',
      ttsLocale: 'ml-IN',
    ),
    Language(
      code: 'or',
      nativeName: 'ଓଡ଼ିଆ',
      englishLabel: 'Odia',
      flagEmoji: '🇮🇳',
      ttsLocale: 'or-IN',
    ),
    Language(
      code: 'pa',
      nativeName: 'ਪੰਜਾਬੀ',
      englishLabel: 'Punjabi',
      flagEmoji: '🇮🇳',
      ttsLocale: 'pa-IN',
    ),
    Language(
      code: 'as',
      nativeName: 'অসমীয়া',
      englishLabel: 'Assamese',
      flagEmoji: '🇮🇳',
      ttsLocale: 'as-IN',
    ),
    Language(
      code: 'ur',
      nativeName: 'اردو',
      englishLabel: 'Urdu',
      flagEmoji: '🇮🇳',
      ttsLocale: 'ur-IN',
    ),
  ];

  static Language fromCode(String code) {
    return supportedLanguages.firstWhere(
      (lang) => lang.code == code,
      orElse: () => supportedLanguages.first,
    );
  }
}
