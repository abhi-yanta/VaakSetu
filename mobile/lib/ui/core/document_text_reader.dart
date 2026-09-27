import 'package:flutter/material.dart';

import '../../data/services/haptic_service.dart';
import '../../data/services/tts_service.dart';
import '../../domain/models/document_analysis.dart';
import '../../domain/models/localized_content.dart';
import 'app_colors.dart';

/// Renders document text with illegal / risky clauses highlighted in red/yellow,
/// so the user can see exactly what does not match a fair legal expectation.
class DocumentTextReader extends StatefulWidget {
  final String text;
  final String langCode;
  final TtsService ttsService;
  final List<ClauseHighlight> highlights;

  const DocumentTextReader({
    super.key,
    required this.text,
    required this.langCode,
    required this.ttsService,
    this.highlights = const [],
  });

  @override
  State<DocumentTextReader> createState() => _DocumentTextReaderState();
}

class _DocumentTextReaderState extends State<DocumentTextReader> {
  int? _activeSentenceIndex;
  bool _isReadingFullText = false;
  String? _activeWarningKey;

  @override
  void initState() {
    super.initState();
    widget.ttsService.addListener(_onTtsStateChanged);
  }

  void _onTtsStateChanged() {
    if (mounted && !widget.ttsService.isPlaying) {
      setState(() {
        _isReadingFullText = false;
        _activeSentenceIndex = null;
        _activeWarningKey = null;
      });
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
        if (part.trim().isNotEmpty) result.add(part.trim());
      }
    }
    return result.isNotEmpty ? result : [fullText];
  }

  bool _sentenceHasHighlight(String sentence) {
    final lower = sentence.toLowerCase();
    for (final h in widget.highlights) {
      if (h.matchedText.isEmpty) continue;
      if (lower.contains(h.matchedText.toLowerCase()) ||
          sentence.contains(h.matchedText)) {
        return true;
      }
    }
    return false;
  }

  ClauseHighlight? _highlightForSentence(String sentence) {
    final lower = sentence.toLowerCase();
    for (final h in widget.highlights) {
      if (h.matchedText.isEmpty) continue;
      if (lower.contains(h.matchedText.toLowerCase()) ||
          sentence.contains(h.matchedText)) {
        return h;
      }
    }
    return null;
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
    final hit = _highlightForSentence(sentence);
    setState(() {
      _isReadingFullText = false;
      _activeSentenceIndex = index;
      _activeWarningKey = hit?.warningKey;
    });
    if (hit != null) {
      final why = LocalizedContent.getWarning(widget.langCode, hit.warningKey);
      widget.ttsService.speak(
        '${LocalizedContent.get(widget.langCode, 'highlighted_clause_speak')}. $sentence. $why',
        widget.langCode,
      );
    } else {
      widget.ttsService.speak(sentence, widget.langCode);
    }
  }

  /// Build RichText spans with yellow/red backgrounds on illegal phrases.
  List<InlineSpan> _buildHighlightedSpans(String text) {
    if (widget.highlights.isEmpty || text.isEmpty) {
      return [
        TextSpan(
          text: text,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ];
    }

    final sorted = [...widget.highlights]
      ..sort((a, b) => a.start.compareTo(b.start));
    final spans = <InlineSpan>[];
    var cursor = 0;

    for (final h in sorted) {
      var start = h.start.clamp(0, text.length);
      var end = h.end.clamp(0, text.length);
      if (end <= start || start < cursor) continue;

      if (start > cursor) {
        spans.add(
          TextSpan(
            text: text.substring(cursor, start),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        );
      }

      final isDanger = h.warningKey.contains('alert_high') ||
          h.warningKey.contains('collateral') ||
          h.warningKey.contains('unpaid') ||
          h.warningKey == 'alert_no_exit';
      final bg = isDanger ? AppColors.dangerRedBg : AppColors.warningYellowBg;
      final fg = isDanger ? AppColors.dangerRed : const Color(0xFF92400E);
      final active = _activeWarningKey == h.warningKey;

      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: GestureDetector(
            onTap: () {
              HapticService.selectionClick();
              setState(() => _activeWarningKey = h.warningKey);
              final why =
                  LocalizedContent.getWarning(widget.langCode, h.warningKey);
              widget.ttsService.speak(
                '${LocalizedContent.get(widget.langCode, 'highlighted_clause_speak')}. ${h.matchedText}. $why',
                widget.langCode,
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 2),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: active ? fg : fg.withValues(alpha: 0.5),
                  width: active ? 2 : 1,
                ),
              ),
              child: Text(
                text.substring(start, end),
                style: TextStyle(
                  color: fg,
                  fontSize: 14,
                  height: 1.45,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
      cursor = end;
    }

    if (cursor < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(cursor),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      );
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.text.trim().isEmpty) {
      return SelectableText(
        LocalizedContent.get(widget.langCode, 'no_text'),
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          height: 1.4,
        ),
      );
    }

    final sentences = _extractSentences(widget.text);
    final readFullLabel =
        LocalizedContent.get(widget.langCode, 'read_full_text');
    final tipText = widget.highlights.isNotEmpty
        ? LocalizedContent.get(widget.langCode, 'tap_highlighted_clause')
        : LocalizedContent.get(widget.langCode, 'tap_sentence_to_listen');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.highlights.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.dangerRedBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.dangerRed.withValues(alpha: 0.5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.highlight_rounded,
                    color: AppColors.dangerRed, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    LocalizedContent.get(
                        widget.langCode, 'illegal_clauses_highlighted'),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Full document with yellow/red highlights (sketch-style)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: Text.rich(
              TextSpan(children: _buildHighlightedSpans(widget.text)),
            ),
          ),
          const SizedBox(height: 14),
        ],

        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: _isReadingFullText
                ? AppColors.dangerRed
                : AppColors.primarySaffron,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          icon: Icon(
            _isReadingFullText
                ? Icons.stop_circle_rounded
                : Icons.volume_up_rounded,
            size: 22,
          ),
          label: Text(
            _isReadingFullText
                ? LocalizedContent.get(widget.langCode, 'stop')
                : readFullLabel,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          onPressed: _toggleFullTextSpeech,
        ),
        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primarySaffron.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.primarySaffron.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.touch_app_rounded,
                color: AppColors.primarySaffronLight,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tipText,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sentences.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final sentence = sentences[index];
            final isSpeaking = _activeSentenceIndex == index;
            final isIllegal = _sentenceHasHighlight(sentence);

            return Material(
              color: isIllegal
                  ? AppColors.dangerRedBg
                  : isSpeaking
                      ? AppColors.surfaceDarkElevated
                      : AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => _speakSentence(index, sentence),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isIllegal
                          ? AppColors.dangerRed
                          : isSpeaking
                              ? AppColors.primarySaffronLight
                              : AppColors.borderDark,
                      width: isIllegal || isSpeaking ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(
                          isIllegal
                              ? Icons.gavel_rounded
                              : isSpeaking
                                  ? Icons.volume_up_rounded
                                  : Icons.play_arrow_outlined,
                          color: isIllegal
                              ? AppColors.dangerRed
                              : isSpeaking
                                  ? AppColors.primarySaffronLight
                                  : AppColors.textMuted,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          sentence,
                          style: TextStyle(
                            color: isIllegal
                                ? AppColors.dangerRed
                                : isSpeaking
                                    ? AppColors.primarySaffron
                                    : AppColors.textPrimary,
                            fontSize: 14,
                            height: 1.45,
                            fontWeight: isIllegal || isSpeaking
                                ? FontWeight.bold
                                : FontWeight.w400,
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
