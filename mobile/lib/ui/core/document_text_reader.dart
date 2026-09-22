import 'package:flutter/material.dart';
import '../../data/services/haptic_service.dart';
import '../../data/services/tts_service.dart';
import '../../domain/models/localized_content.dart';
import 'app_colors.dart';

/// DocumentTextReader renders document text with full-document verbalization
/// and sentence-level interactive reading capabilities.
class DocumentTextReader extends StatefulWidget {
  final String text;
  final String langCode;
  final TtsService ttsService;

  const DocumentTextReader({
    super.key,
    required this.text,
    required this.langCode,
    required this.ttsService,
  });

  @override
  State<DocumentTextReader> createState() => _DocumentTextReaderState();
}

class _DocumentTextReaderState extends State<DocumentTextReader> {
  int? _activeSentenceIndex;
  bool _isReadingFullText = false;

  @override
  void initState() {
    super.initState();
    widget.ttsService.addListener(_onTtsStateChanged);
  }

  void _onTtsStateChanged() {
    if (mounted) {
      if (!widget.ttsService.isPlaying) {
        setState(() {
          _isReadingFullText = false;
          _activeSentenceIndex = null;
        });
      }
    }
  }

  @override
  void dispose() {
    widget.ttsService.removeListener(_onTtsStateChanged);
    super.dispose();
  }

  List<String> _extractSentences(String fullText) {
    final lines = fullText.split('\n');
    final List<String> result = [];
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      final parts = trimmed.split(RegExp(r'(?<=[।\.\?!])\s+'));
      for (final part in parts) {
        if (part.trim().isNotEmpty) {
          result.add(part.trim());
        }
      }
    }
    return result.isNotEmpty ? result : [fullText];
  }

  void _toggleFullTextSpeech() {
    HapticService.selectionClick();
    if (_isReadingFullText || widget.ttsService.isPlaying) {
      widget.ttsService.stop();
      setState(() {
        _isReadingFullText = false;
        _activeSentenceIndex = null;
      });
    } else {
      setState(() {
        _isReadingFullText = true;
        _activeSentenceIndex = null;
      });
      widget.ttsService.speak(widget.text, widget.langCode);
    }
  }

  void _speakSentence(int index, String sentence) {
    HapticService.selectionClick();
    setState(() {
      _isReadingFullText = false;
      _activeSentenceIndex = index;
    });
    widget.ttsService.speak(sentence, widget.langCode);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.text.trim().isEmpty) {
      return SelectableText(
        LocalizedContent.get(widget.langCode, 'no_text'),
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
      );
    }

    final sentences = _extractSentences(widget.text);
    final readFullLabel = LocalizedContent.get(widget.langCode, 'read_full_text');
    final tipText = LocalizedContent.get(widget.langCode, 'tap_sentence_to_listen');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Full Document Verbalization Button
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: _isReadingFullText ? AppColors.dangerRed : AppColors.primarySaffron,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
          ),
          icon: Icon(
            _isReadingFullText ? Icons.stop_circle_rounded : Icons.volume_up_rounded,
            size: 22,
          ),
          label: Text(
            _isReadingFullText ? LocalizedContent.get(widget.langCode, 'stop') : readFullLabel,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          onPressed: _toggleFullTextSpeech,
        ),
        const SizedBox(height: 12),

        // Helper instruction banner
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
              const Icon(Icons.touch_app_rounded, color: AppColors.primarySaffronLight, size: 16),
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
        const SizedBox(height: 14),

        // Sentence-by-sentence reading list
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sentences.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final sentence = sentences[index];
            final isSpeaking = _activeSentenceIndex == index;

            return Material(
              color: isSpeaking ? AppColors.surfaceDarkElevated : AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => _speakSentence(index, sentence),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSpeaking ? AppColors.primarySaffronLight : AppColors.borderDark,
                      width: isSpeaking ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(
                          isSpeaking ? Icons.volume_up_rounded : Icons.play_arrow_outlined,
                          color: isSpeaking ? AppColors.primarySaffronLight : AppColors.textMuted,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          sentence,
                          style: TextStyle(
                            color: isSpeaking ? Colors.white : AppColors.textPrimary,
                            fontSize: 14,
                            height: 1.45,
                            fontWeight: isSpeaking ? FontWeight.bold : FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
