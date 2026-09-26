import 'package:flutter/material.dart';
import '../../../data/services/haptic_service.dart';
import '../../../data/services/tts_service.dart';
import '../../../domain/models/localized_content.dart';
import '../../core/app_colors.dart';
import '../../core/listen_again_button.dart';
import '../../core/tactile_button.dart';
import '../../core/vaaksetu_mascot.dart';

class _TourPageDef {
  final String titleKey;
  final String bodyKey;
  final String speakKey;
  final MascotPose pose;
  final IconData icon;

  const _TourPageDef({
    required this.titleKey,
    required this.bodyKey,
    required this.speakKey,
    required this.pose,
    required this.icon,
  });
}

/// Feature showcase — standing character with a hand gesture per feature.
const _tourPages = [
  _TourPageDef(
    titleKey: 'tour_scan_title',
    bodyKey: 'tour_scan_body',
    speakKey: 'tour_scan_speak',
    pose: MascotPose.point,
    icon: Icons.document_scanner_rounded,
  ),
  _TourPageDef(
    titleKey: 'tour_safety_title',
    bodyKey: 'tour_safety_body',
    speakKey: 'tour_safety_speak',
    pose: MascotPose.wave,
    icon: Icons.shield_rounded,
  ),
  _TourPageDef(
    titleKey: 'tour_form_title',
    bodyKey: 'tour_form_body',
    speakKey: 'tour_form_speak',
    pose: MascotPose.namaste,
    icon: Icons.edit_note_rounded,
  ),
  _TourPageDef(
    titleKey: 'tour_langs_title',
    bodyKey: 'tour_langs_body',
    speakKey: 'tour_langs_speak',
    pose: MascotPose.celebrate,
    icon: Icons.translate_rounded,
  ),
];

/// Feature showcase with the friendly VaakSetu mascot guide.
class CharacterWelcomeView extends StatefulWidget {
  final TtsService ttsService;
  final String selectedLang;
  final VoidCallback onFinished;

  const CharacterWelcomeView({
    super.key,
    required this.ttsService,
    required this.selectedLang,
    required this.onFinished,
  });

  @override
  State<CharacterWelcomeView> createState() => _CharacterWelcomeViewState();
}

class _CharacterWelcomeViewState extends State<CharacterWelcomeView> {
  final PageController _pageController = PageController();
  int _page = 0;
  bool _hasSpoken = false;

  String _t(String key) => LocalizedContent.get(widget.selectedLang, key);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _hasSpoken) return;
      _hasSpoken = true;
      _speakPage(0);
    });
  }

  @override
  void dispose() {
    // Parent navigation already stops TTS; avoid racing a late stop() against
    // the next screen's speak().
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    if (!mounted) return;
    setState(() => _page = index);
    _speakPage(index);
  }

  void _speakPage(int index) {
    if (!mounted) return;
    if (index < 0 || index >= _tourPages.length) return;
    widget.ttsService.speak(
      _t(_tourPages[index].speakKey),
      widget.selectedLang,
    );
  }

  void _goToPage(int index) {
    if (!mounted) return;
    HapticService.lightTap();
    widget.ttsService.stop();
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  void _onPrimaryAction() {
    HapticService.lightTap();
    if (_page < _tourPages.length - 1) {
      _goToPage(_page + 1);
    } else {
      widget.ttsService.stop();
      widget.onFinished();
    }
  }

  void _onSkip() {
    HapticService.lightTap();
    widget.ttsService.stop();
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _tourPages.length - 1;

    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _onSkip,
            child: Text(
              _t('skip'),
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _tourPages.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              final page = _tourPages[index];
              return Column(
                children: [
                  Text(
                    _t(page.titleKey),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          page.icon,
                          color: AppColors.primarySaffronLight,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _t(page.bodyKey),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final maxW = constraints.maxWidth;
                        final maxH = constraints.maxHeight;
                        final sizeByH = maxH / 1.2;
                        final sizeByW = maxW * 0.92;
                        final size = sizeByH < sizeByW ? sizeByH : sizeByW;
                        return Center(
                          child: VaakSetuMascot(
                            key: ValueKey('mascot_${page.pose}'),
                            size: size.clamp(180.0, 360.0),
                            pose: page.pose,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_tourPages.length, (i) {
            final active = i == _page;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: active ? 22 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: active
                    ? AppColors.primarySaffron
                    : AppColors.borderDark,
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }),
        ),
        const SizedBox(height: 18),

        ListenAgainButton(
          langCode: widget.selectedLang,
          height: 52,
          fontSize: 15,
          onPressed: () => _speakPage(_page),
        ),
        const SizedBox(height: 10),

        TactileButton(
          label: isLast ? _t('continue') : _t('next'),
          icon: Icon(
            isLast ? Icons.arrow_forward_rounded : Icons.navigate_next_rounded,
            color: Colors.white,
            size: 26,
          ),
          style: isLast ? TactileButtonStyle.safe : TactileButtonStyle.primary,
          height: 68,
          fontSize: 18,
          onPressed: _onPrimaryAction,
        ),

        if (_page > 0)
          TextButton(
            onPressed: () => _goToPage(_page - 1),
            child: Text(
              _t('back'),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          )
        else
          const SizedBox(height: 12),
      ],
    );
  }
}
