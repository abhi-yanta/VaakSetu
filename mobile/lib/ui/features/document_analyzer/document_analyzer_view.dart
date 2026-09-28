import 'package:flutter/material.dart';
import '../../../data/services/haptic_service.dart';
import '../../../data/services/tts_service.dart';
import '../../../domain/models/document_analysis.dart';
import '../../../domain/models/localized_content.dart';
import '../../core/app_colors.dart';
import '../../core/document_text_reader.dart';
import '../../core/listen_again_button.dart';
import '../../core/security_badge.dart';
import '../../core/tactile_button.dart';
import '../../core/wave_visualizer.dart';
import '../form_guide/form_field_guide_view.dart';

class DocumentAnalyzerView extends StatefulWidget {
  final DocumentAnalysis analysis;
  final String selectedLang;
  final TtsService ttsService;
  final VoidCallback onReset;
  final bool initialShowFormGuide;
  /// TEMP: when false, Form Guide tab/banner are hidden.
  final bool formGuideEnabled;

  const DocumentAnalyzerView({
    super.key,
    required this.analysis,
    required this.selectedLang,
    required this.ttsService,
    required this.onReset,
    this.initialShowFormGuide = false,
    this.formGuideEnabled = false,
  });

  @override
  DocumentAnalyzerViewState createState() => DocumentAnalyzerViewState();
}

class DocumentAnalyzerViewState extends State<DocumentAnalyzerView> {
  bool _isPlaying = false;
  String? _activeSpeakingWarning;
  late bool _showFormGuide;
  final GlobalKey<FormFieldGuideViewState> _formGuideKey =
      GlobalKey<FormFieldGuideViewState>();

  /// Handles Android system back while the form guide is open.
  /// Returns true if consumed; false so the parent can leave the analyzer.
  bool handleSystemBack() {
    if (_showFormGuide) {
      return _formGuideKey.currentState?.handleSystemBack() ?? false;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _showFormGuide =
        widget.formGuideEnabled && widget.initialShowFormGuide;
    widget.ttsService.addListener(_onTtsChanged);
    _isPlaying = widget.ttsService.isPlaying;

    // Trigger initial voice overview if not in form guide mode
    if (!_showFormGuide) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _announceInitialOverview();
      });
    }
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
    if (!mounted) return;
    final speech = LocalizedContent.buildResultSpeech(
      widget.selectedLang,
      widget.analysis,
    );
    widget.ttsService.speak(speech, widget.selectedLang);
  }

  void _speakAll() {
    if (_isPlaying) {
      widget.ttsService.stop();
      return;
    }
    final speech = LocalizedContent.buildResultSpeech(
      widget.selectedLang,
      widget.analysis,
    );
    widget.ttsService.speak(speech, widget.selectedLang);
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
      waveColor = AppColors.infoBlue;
    } else if (widget.analysis.severity == DocumentSeverity.danger) {
      waveColor = AppColors.dangerRed;
    } else if (widget.analysis.severity == DocumentSeverity.warning) {
      waveColor = AppColors.warningYellow;
    } else {
      waveColor = AppColors.safeGreen;
    }

    if (_showFormGuide && widget.formGuideEnabled) {
      return FormFieldGuideView(
        key: _formGuideKey,
        rawText: widget.analysis.rawText,
        selectedLang: widget.selectedLang,
        ttsService: widget.ttsService,
        onBack: () {
          widget.ttsService.stop();
          widget.onReset();
        },
        onSwitchToSafety: () {
          widget.ttsService.stop();
          setState(() => _showFormGuide = false);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _announceInitialOverview();
          });
        },
      );
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
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 24),
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
                  ui['result'] ?? LocalizedContent.get(widget.selectedLang, 'result'),
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 12),

          if (widget.formGuideEnabled) ...[
            // Mode Switcher Bar
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.safeGreen.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.safeGreen),
                    ),
                    child: Text(
                      '🛡️ ${LocalizedContent.get(widget.selectedLang, 'safety_tab')}',
                      style: const TextStyle(
                        color: AppColors.safeGreen,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      widget.ttsService.stop();
                      setState(() => _showFormGuide = true);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderDark),
                      ),
                      child: Text(
                        '📝 ${LocalizedContent.get(widget.selectedLang, 'form_guide_tab')}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Suggestion banner to switch to Form Guide
            InkWell(
              onTap: () {
                widget.ttsService.stop();
                setState(() => _showFormGuide = true);
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primarySaffron.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primarySaffron.withOpacity(0.6)),
                ),
                child: Row(
                  children: [
                    const Text('📝', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LocalizedContent.get(widget.selectedLang, 'learn_form_fill'),
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            LocalizedContent.get(widget.selectedLang, 'learn_form_fill_desc'),
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.primarySaffron, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Security Status Card
          SecurityBadge(
            analysis: widget.analysis,
            langCode: widget.selectedLang,
          ),
          const SizedBox(height: 14),

          // Elaborate assurance (legal / illegal why / unrecognized / unreadable)
          _buildAssuranceCard(),
          const SizedBox(height: 16),

          // Dynamic Wave Visualizer
          WaveVisualizer(
            isPlaying: _isPlaying,
            barColor: waveColor,
          ),
          const SizedBox(height: 18),

          // Audio Controls — Listen full-width; Guide + Listen again share equal space
          // so "निर्देश" never crushes into निर्दे / श.
          TactileButton(
            label: _isPlaying
                ? (ui['stop'] ?? LocalizedContent.get(widget.selectedLang, 'stop'))
                : (ui['listen_all'] ??
                    LocalizedContent.get(widget.selectedLang, 'listen_all')),
            icon: Icon(
              _isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 26,
            ),
            style: _isPlaying
                ? TactileButtonStyle.danger
                : TactileButtonStyle.primary,
            height: 64,
            fontSize: 17,
            onPressed: _speakAll,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TactileButton(
                  label: ui['guide'] ??
                      LocalizedContent.get(widget.selectedLang, 'guide'),
                  icon: const Icon(
                    Icons.help_outline_rounded,
                    color: AppColors.textPrimary,
                    size: 22,
                  ),
                  style: TactileButtonStyle.secondary,
                  height: 56,
                  fontSize: 15,
                  iconSpacing: 8,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  onPressed: () {
                    widget.ttsService.speakPrompt('welcome', widget.selectedLang);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ListenAgainButton(
                  langCode: widget.selectedLang,
                  height: 56,
                  fontSize: 15,
                  onPressed: () {
                    HapticService.lightTap();
                    // Always this screen's narrative — not last warning/welcome.
                    _announceInitialOverview();
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
                  color: widget.analysis.isUnrecognized ? AppColors.infoBlue : AppColors.dangerRed,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.analysis.category == DocumentCategory.unclear ||
                          widget.analysis.category == DocumentCategory.unrecognized
                      ? (ui['notice'] ?? LocalizedContent.get(widget.selectedLang, 'notice'))
                      : widget.analysis.severity == DocumentSeverity.danger
                          ? LocalizedContent.get(
                              widget.selectedLang, 'result_illegal_clauses')
                          : "${ui['red_flags'] ?? LocalizedContent.get(widget.selectedLang, 'red_flags')} (${widget.analysis.warningKeys.length})",
                  style: const TextStyle(
                    color: AppColors.textPrimary,
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
                              ? (isInfo ? AppColors.infoBlue : AppColors.dangerRed)
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
                              color: (isInfo ? AppColors.infoBlueBg : AppColors.dangerRedBg),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isInfo ? Icons.lightbulb_outline_rounded : Icons.priority_high_rounded,
                              color: isInfo ? AppColors.infoBlue : AppColors.dangerRed,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              desc,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
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
                                  ? (isInfo ? AppColors.infoBlue : AppColors.dangerRed)
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

          // Document with illegal clauses highlighted (always open when risky)
          if (widget.analysis.hasIllegalHighlights ||
              widget.analysis.rawText.trim().isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  widget.analysis.hasIllegalHighlights
                      ? Icons.highlight_rounded
                      : Icons.article_outlined,
                  color: widget.analysis.hasIllegalHighlights
                      ? AppColors.dangerRed
                      : AppColors.textMuted,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.analysis.hasIllegalHighlights
                        ? LocalizedContent.get(
                            widget.selectedLang, 'document_with_highlights')
                        : (ui['view_raw'] ??
                            LocalizedContent.get(
                                widget.selectedLang, 'view_raw')),
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceDarkElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.analysis.hasIllegalHighlights
                      ? AppColors.dangerRed.withValues(alpha: 0.45)
                      : AppColors.borderDark,
                ),
              ),
              child: DocumentTextReader(
                text: widget.analysis.rawText,
                langCode: widget.selectedLang,
                ttsService: widget.ttsService,
                highlights: widget.analysis.highlights,
              ),
            ),
            const SizedBox(height: 28),
          ] else ...[
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Text(
                  ui['view_raw'] ??
                      LocalizedContent.get(widget.selectedLang, 'view_raw'),
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                ),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDarkElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: DocumentTextReader(
                      text: widget.analysis.rawText,
                      langCode: widget.selectedLang,
                      ttsService: widget.ttsService,
                      highlights: widget.analysis.highlights,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
          ],
        ],
      ),
    );
  }

  Widget _buildAssuranceCard() {
    final assurance = LocalizedContent.getResultAssurance(
      widget.selectedLang,
      widget.analysis,
    );

    Color border;
    Color bg;
    IconData icon;
    if (widget.analysis.category == DocumentCategory.unclear) {
      border = AppColors.infoBlue;
      bg = AppColors.infoBlueBg;
      icon = Icons.visibility_off_outlined;
    } else if (widget.analysis.category == DocumentCategory.unrecognized) {
      border = AppColors.infoBlue;
      bg = AppColors.infoBlueBg;
      icon = Icons.help_outline_rounded;
    } else if (widget.analysis.severity == DocumentSeverity.safe) {
      border = AppColors.safeGreen;
      bg = AppColors.safeGreenBg;
      icon = Icons.verified_rounded;
    } else if (widget.analysis.severity == DocumentSeverity.warning) {
      border = AppColors.warningYellow;
      bg = AppColors.warningYellowBg;
      icon = Icons.info_outline_rounded;
    } else {
      border = AppColors.dangerRed;
      bg = AppColors.dangerRedBg;
      icon = Icons.gpp_bad_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: border, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assurance.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  assurance.body,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
