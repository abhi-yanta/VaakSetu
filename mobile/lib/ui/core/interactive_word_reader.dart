import 'package:flutter/material.dart';
import '../../data/services/haptic_service.dart';
import '../../data/services/tts_service.dart';
import '../../domain/models/localized_content.dart';
import 'app_colors.dart';

/// InteractiveWordReader renders document text as interactive, touchable word tiles.
/// Tapping any word instantly verbalizes it via TTS in the user's selected language.
class InteractiveWordReader extends StatefulWidget {
  final String text;
  final String langCode;
  final TtsService ttsService;

  const InteractiveWordReader({
    super.key,
    required this.text,
    required this.langCode,
    required this.ttsService,
  });

  @override
  State<InteractiveWordReader> createState() => _InteractiveWordReaderState();
}

class _InteractiveWordReaderState extends State<InteractiveWordReader> {
  int? _activeWordIndex;
  bool _isWordMode = true;

  @override
  Widget build(BuildContext context) {
    if (widget.text.trim().isEmpty) {
      return SelectableText(
        LocalizedContent.get(widget.langCode, 'no_text'),
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
      );
    }

    final words = widget.text.trim().split(RegExp(r'\s+'));
    final tipText = LocalizedContent.get(widget.langCode, 'tap_word_to_listen');
    final modeLabel = LocalizedContent.get(widget.langCode, 'word_mode');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mode Switcher Header Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.touch_app_rounded, color: AppColors.primarySaffronLight, size: 18),
                const SizedBox(width: 6),
                Text(
                  modeLabel,
                  style: const TextStyle(
                    color: AppColors.primarySaffronLight,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () {
                HapticService.selectionClick();
                setState(() {
                  _isWordMode = !_isWordMode;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isWordMode ? Icons.notes_rounded : Icons.touch_app_rounded,
                      color: Colors.white70,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isWordMode ? 'Full Text' : 'Tap-to-Speak',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (_isWordMode) ...[
          // Sub-banner instructions for users
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primarySaffron.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primarySaffron.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.volume_up_rounded, color: AppColors.primarySaffron, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tipText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Tappable Word Flow
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(words.length, (index) {
              final rawWord = words[index];
              final isSpeaking = _activeWordIndex == index;

              return Material(
                color: isSpeaking ? AppColors.primarySaffron : AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () {
                    HapticService.selectionClick();
                    setState(() {
                      _activeWordIndex = index;
                    });

                    // Strip punctuation for accurate TTS audio playback
                    final cleanWord = rawWord.replaceAll(
                      RegExp(r'[^\w\u0900-\u097F\u0B80-\u0BFF\u0C00-\u0C7F\u0D00-\u0D7F\u0980-\u09FF\u0A80-\u0AFF\u0A00-\u0A7F\u0600-\u06FF]'),
                      '',
                    );
                    final wordToSpeak = cleanWord.isNotEmpty ? cleanWord : rawWord;

                    widget.ttsService.speak(wordToSpeak, widget.langCode);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSpeaking ? AppColors.primarySaffronLight : AppColors.borderDark,
                        width: isSpeaking ? 1.5 : 1.0,
                      ),
                    ),
                    child: Text(
                      rawWord,
                      style: TextStyle(
                        color: isSpeaking ? Colors.white : AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: isSpeaking ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ] else ...[
          // Plain Selectable Text View
          SelectableText(
            widget.text,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
          ),
        ],
      ],
    );
  }
}
