import 'package:flutter/material.dart';
import '../../../data/services/haptic_service.dart';
import '../../../domain/models/language.dart';
import '../../../domain/models/localized_content.dart';
import '../../core/app_colors.dart';

class LanguageSelectorView extends StatelessWidget {
  final Function(String langCode) onLanguageSelected;

  const LanguageSelectorView({
    super.key,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.translate_rounded, color: AppColors.primarySaffronLight, size: 28),
              const SizedBox(width: 10),
              Text(
                LocalizedContent.get('hi', 'select_lang'),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.only(bottom: 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.45,
            ),
            itemCount: Language.supportedLanguages.length,
            itemBuilder: (context, index) {
              final lang = Language.supportedLanguages[index];
              return _LanguageTile(
                language: lang,
                onTap: () {
                  HapticService.selectionClick();
                  onLanguageSelected(lang.code);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final Language language;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.language,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceDark,
      borderRadius: BorderRadius.circular(16),
      elevation: 3,
      shadowColor: Colors.black45,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.primarySaffron.withOpacity(0.25),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderDark, width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                language.flagEmoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 6),
              Text(
                language.nativeName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                language.englishLabel,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
