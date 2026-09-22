import 'package:flutter/material.dart';
import '../../../data/services/haptic_service.dart';
import '../../../data/services/tts_service.dart';
import '../../../domain/models/document_analysis.dart';
import '../../../domain/models/localized_content.dart';
import '../../core/app_colors.dart';
import '../../core/document_text_reader.dart';
import '../../core/security_badge.dart';
import '../../core/tactile_button.dart';
import '../../core/wave_visualizer.dart';

class DocumentAnalyzerView extends StatefulWidget {
  final DocumentAnalysis analysis;
  final String selectedLang;
  final TtsService ttsService;
  final VoidCallback onReset;

  const DocumentAnalyzerView({
    super.key,
    required this.analysis,
    required this.selectedLang,
    required this.ttsService,
    required this.onReset,
  });

  @override
  State<DocumentAnalyzerView> createState() => _DocumentAnalyzerViewState();
}

class _DocumentAnalyzerViewState extends State<DocumentAnalyzerView> {
  bool _isPlaying = false;
  String? _activeSpeakingWarning;

  @override
  void initState() {
    super.initState();
    widget.ttsService.addListener(_onTtsChanged);
    _isPlaying = widget.ttsService.isPlaying;

    // Trigger initial voice overview
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _announceInitialOverview();
    });
  }

  void _onTtsChanged() {
    if (mounted) {
      setState(() {
        _isPlaying = widget.ttsService.isPlaying;
        if (!_isPlaying) {
          _activeSpeakingWarning = null;
        }
      });
    }
  }

  void _announceInitialOverview() {
    final categoryName = LocalizedContent.get(widget.selectedLang, widget.analysis.category.key);
    String summary;

    if (widget.analysis.category == DocumentCategory.unclear) {
      summary = LocalizedContent.getWarning(widget.selectedLang, 'alert_unclear_image');
    } else if (widget.analysis.isUnrecognized) {
      summary = LocalizedContent.getWarning(widget.selectedLang, 'info_non_legal_document');
    } else if (widget.analysis.severity == DocumentSeverity.safe) {
      summary = "$categoryName. ${LocalizedContent.get(widget.selectedLang, 'safe_doc')}.";
    } else if (widget.analysis.severity == DocumentSeverity.warning) {
      summary = "$categoryName. ${LocalizedContent.get(widget.selectedLang, 'warning_doc')}.";
    } else {
      summary = "$categoryName. ${LocalizedContent.get(widget.selectedLang, 'danger_doc')}.";
    }

    widget.ttsService.speak(summary, widget.selectedLang);
  }

  void _speakAll() {
    if (_isPlaying) {
      widget.ttsService.stop();
      return;
    }

    final categoryName = LocalizedContent.get(widget.selectedLang, widget.analysis.category.key);
    final buffer = StringBuffer();

    if (widget.analysis.category == DocumentCategory.unclear) {
      buffer.write(LocalizedContent.getWarning(widget.selectedLang, 'alert_unclear_image'));
    } else if (widget.analysis.isUnrecognized) {
      buffer.write(LocalizedContent.getWarning(widget.selectedLang, 'info_non_legal_document'));
    } else {
      buffer.write("$categoryName. ");
      if (widget.analysis.severity == DocumentSeverity.safe) {
        buffer.write(LocalizedContent.get(widget.selectedLang, 'safe_doc'));
      } else if (widget.analysis.severity == DocumentSeverity.warning) {
        buffer.write(LocalizedContent.get(widget.selectedLang, 'warning_doc'));
      } else {
        buffer.write(LocalizedContent.get(widget.selectedLang, 'danger_doc'));
      }
      buffer.write(". ");

      if (widget.analysis.warningKeys.isNotEmpty) {
        buffer.write("${LocalizedContent.get(widget.selectedLang, 'red_flags')}: ");
        for (int i = 0; i < widget.analysis.warningKeys.length; i++) {
          final key = widget.analysis.warningKeys[i];
          final desc = LocalizedContent.getWarning(widget.selectedLang, key);
          buffer.write("${i + 1}. $desc ");
        }
      }
    }

    widget.ttsService.speak(buffer.toString(), widget.selectedLang);
  }

  void _speakSingleWarning(String key) {
    HapticService.selectionClick();
    setState(() => _activeSpeakingWarning = key);
    final desc = LocalizedContent.getWarning(widget.selectedLang, key);
    widget.ttsService.speak(desc, widget.selectedLang);
  }

  @override
  void dispose() {
    widget.ttsService.removeListener(_onTtsChanged);
    widget.ttsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ui = LocalizedContent.uiTexts[widget.selectedLang] ?? LocalizedContent.uiTexts['hi']!;

    Color waveColor;
    if (widget.analysis.isUnrecognized) {
      waveColor = const Color(0xFF38BDF8);
    } else if (widget.analysis.severity == DocumentSeverity.danger) {
      waveColor = AppColors.dangerRed;
    } else if (widget.analysis.severity == DocumentSeverity.warning) {
      waveColor = AppColors.warningYellow;
    } else {
      waveColor = AppColors.safeGreen;
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
                onPressed: () {
                  widget.ttsService.stop();
                  HapticService.lightTap();
                  widget.onReset();
                },
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: Text(
                  ui['result'] ?? 'परिणाम / Result',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 14),

          // Security Status Card
          SecurityBadge(
            analysis: widget.analysis,
            langCode: widget.selectedLang,
          ),
          const SizedBox(height: 16),

          // Dynamic Wave Visualizer
          WaveVisualizer(
            isPlaying: _isPlaying,
            barColor: waveColor,
          ),
          const SizedBox(height: 18),

          // Audio Controls
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TactileButton(
                  label: _isPlaying ? (ui['stop'] ?? 'आवाज बंद करें') : (ui['listen_all'] ?? 'पूरी जानकारी सुनें'),
                  icon: Icon(_isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 26),
                  style: _isPlaying ? TactileButtonStyle.danger : TactileButtonStyle.primary,
                  height: 64,
                  fontSize: 17,
                  onPressed: _speakAll,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: TactileButton(
                  label: ui['guide'] ?? 'निर्देश',
                  icon: const Icon(Icons.help_outline_rounded, color: Colors.white, size: 22),
                  style: TactileButtonStyle.secondary,
                  height: 64,
                  fontSize: 15,
                  onPressed: () {
                    widget.ttsService.speakPrompt('welcome', widget.selectedLang);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Warning Cards or Informational Guidance
          if (widget.analysis.warningKeys.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  widget.analysis.isUnrecognized ? Icons.info_outline_rounded : Icons.warning_amber_rounded,
                  color: widget.analysis.isUnrecognized ? const Color(0xFF38BDF8) : AppColors.dangerRed,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.analysis.isUnrecognized
                      ? (ui['notice'] ?? 'महत्वपूर्ण सूचना')
                      : "${ui['red_flags'] ?? 'खतरे की चेतावनी'} (${widget.analysis.warningKeys.length})",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.analysis.warningKeys.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final key = widget.analysis.warningKeys[index];
                final desc = LocalizedContent.getWarning(widget.selectedLang, key);
                final isCurrentSpeaking = _activeSpeakingWarning == key;
                final isInfo = widget.analysis.isUnrecognized;

                return Material(
                  color: isCurrentSpeaking ? AppColors.surfaceDarkElevated : AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: () => _speakSingleWarning(key),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCurrentSpeaking
                              ? (isInfo ? const Color(0xFF38BDF8) : AppColors.dangerRed)
                              : AppColors.borderDark,
                          width: isCurrentSpeaking ? 2.0 : 1.0,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (isInfo ? const Color(0xFF0284C7) : AppColors.dangerRedBg).withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isInfo ? Icons.lightbulb_outline_rounded : Icons.priority_high_rounded,
                              color: isInfo ? const Color(0xFF38BDF8) : AppColors.dangerRed,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              desc,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                height: 1.45,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              isCurrentSpeaking ? Icons.volume_up_rounded : Icons.volume_down_rounded,
                              color: isCurrentSpeaking
                                  ? (isInfo ? const Color(0xFF38BDF8) : AppColors.dangerRed)
                                  : AppColors.textMuted,
                            ),
                            onPressed: () => _speakSingleWarning(key),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],

          // Raw Text Inspector
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: Text(
                ui['view_raw'] ?? 'मूल दस्तावेज़ का पाठ (टैक्स्ट)',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: DocumentTextReader(
                    text: widget.analysis.rawText,
                    langCode: widget.selectedLang,
                    ttsService: widget.ttsService,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}
