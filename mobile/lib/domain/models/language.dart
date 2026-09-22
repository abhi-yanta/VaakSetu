/// Supported Indic languages with native names, script codes, and TTS locales.
class Language {
  final String code;
  final String nativeName;
  final String englishLabel;

  /// A single iconic character from this language's script, used as a visual badge.
  final String scriptChar;
  final String ttsLocale;

  const Language({
    required this.code,
    required this.nativeName,
    required this.englishLabel,
    required this.scriptChar,
    required this.ttsLocale,
  });

  static const List<Language> supportedLanguages = [
    Language(
      code: 'hi',
      nativeName: 'हिन्दी',
      englishLabel: 'Hindi',
      scriptChar: 'अ',
      ttsLocale: 'hi-IN',
    ),
    Language(
      code: 'ta',
      nativeName: 'தமிழ்',
      englishLabel: 'Tamil',
      scriptChar: 'அ',
      ttsLocale: 'ta-IN',
    ),
    Language(
      code: 'te',
      nativeName: 'తెలుగు',
      englishLabel: 'Telugu',
      scriptChar: 'అ',
      ttsLocale: 'te-IN',
    ),
    Language(
      code: 'mr',
      nativeName: 'मराठी',
      englishLabel: 'Marathi',
      scriptChar: 'म',
      ttsLocale: 'mr-IN',
    ),
    Language(
      code: 'bn',
      nativeName: 'বাংলা',
      englishLabel: 'Bengali',
      scriptChar: 'অ',
      ttsLocale: 'bn-IN',
    ),
    Language(
      code: 'gu',
      nativeName: 'ગુજરાતી',
      englishLabel: 'Gujarati',
      scriptChar: 'અ',
      ttsLocale: 'gu-IN',
    ),
    Language(
      code: 'kn',
      nativeName: 'ಕನ್ನಡ',
      englishLabel: 'Kannada',
      scriptChar: 'ಅ',
      ttsLocale: 'kn-IN',
    ),
    Language(
      code: 'ml',
      nativeName: 'മലയാളം',
      englishLabel: 'Malayalam',
      scriptChar: 'അ',
      ttsLocale: 'ml-IN',
    ),
    Language(
      code: 'or',
      nativeName: 'ଓଡ଼ିଆ',
      englishLabel: 'Odia',
      scriptChar: 'ଅ',
      ttsLocale: 'or-IN',
    ),
    Language(
      code: 'pa',
      nativeName: 'ਪੰਜਾਬੀ',
      englishLabel: 'Punjabi',
      scriptChar: 'ਅ',
      ttsLocale: 'pa-IN',
    ),
    Language(
      code: 'as',
      nativeName: 'অসমীয়া',
      englishLabel: 'Assamese',
      scriptChar: 'ক',
      ttsLocale: 'as-IN',
    ),
    Language(
      code: 'ur',
      nativeName: 'اردو',
      englishLabel: 'Urdu',
      scriptChar: 'ا',
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
