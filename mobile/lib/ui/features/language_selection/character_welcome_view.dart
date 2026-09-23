import 'package:flutter/material.dart';
import '../../../data/services/haptic_service.dart';
import '../../../data/services/tts_service.dart';
import '../../core/app_colors.dart';
import '../../core/tactile_button.dart';
import '../../core/vaaksetu_mascot.dart';

class _TourPage {
  final String titleHi;
  final String titleEn;
  final String bodyHi;
  final String speakText;
  final MascotPose pose;
  final IconData icon;

  const _TourPage({
    required this.titleHi,
    required this.titleEn,
    required this.bodyHi,
    required this.speakText,
    required this.pose,
    required this.icon,
  });
}

/// Feature showcase — standing character with a hand gesture per feature.
const _tourPages = [
  _TourPage(
    titleHi: 'कैमरा स्कैन',
    titleEn: 'Document Scan',
    bodyHi: 'दस्तावेज़ की फोटो लें — हम पाठ पढ़कर बताएंगे।',
    speakText:
        'फ़ीचर एक: कैमरा स्कैन। दस्तावेज़ की फोटो लें, और वाक् सेतु पाठ पढ़कर आवाज़ में बताएगा।',
    pose: MascotPose.point,
    icon: Icons.document_scanner_rounded,
  ),
  _TourPage(
    titleHi: 'सुरक्षा जांच',
    titleEn: 'Safety Check',
    bodyHi: 'खतरे और लाल झंडे तुरंत पहचाने जाते हैं।',
    speakText:
        'फ़ीचर दो: सुरक्षा जांच। दस्तावेज़ में धोखाधड़ी या खतरे के संकेत मिलने पर तुरंत चेतावनी मिलेगी।',
    pose: MascotPose.wave,
    icon: Icons.shield_rounded,
  ),
  _TourPage(
    titleHi: 'फॉर्म गाइड',
    titleEn: 'Form Guide',
    bodyHi: 'हर फ़ील्ड पर कदम-दर-कदम भरने की मदद।',
    speakText:
        'फ़ीचर तीन: फॉर्म गाइड। पंजीकरण फ़ॉर्म के हर खाने को क्रम से समझाया जाएगा।',
    pose: MascotPose.namaste,
    icon: Icons.edit_note_rounded,
  ),
  _TourPage(
    titleHi: '१२ भाषाएँ',
    titleEn: '12 Languages',
    bodyHi: 'हिंदी से उर्दू तक — अपनी भाषा चुनें।',
    speakText:
        'फ़ीचर चार: बारह भाषाओं का समर्थन। आगे बढ़ने पर अपनी पसंदीदा भाषा चुनें।',
    pose: MascotPose.celebrate,
    icon: Icons.translate_rounded,
  ),
];

/// Feature showcase with the friendly VaakSetu mascot guide.
class CharacterWelcomeView extends StatefulWidget {
  final TtsService ttsService;
  final VoidCallback onFinished;

  const CharacterWelcomeView({
    super.key,
    required this.ttsService,
    required this.onFinished,
  });

  @override
  State<CharacterWelcomeView> createState() => _CharacterWelcomeViewState();
}

class _CharacterWelcomeViewState extends State<CharacterWelcomeView> {
  final PageController _pageController = PageController();
  int _page = 0;
  bool _hasSpoken = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasSpoken) {
        _hasSpoken = true;
        _speakPage(0);
      }
    });
  }

  @override
  void dispose() {
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
    widget.ttsService.speak(_tourPages[index].speakText, 'hi');
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
            child: const Text(
              'छोड़ें / Skip',
              style: TextStyle(
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
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      page.titleHi,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      page.titleEn,
                      style: const TextStyle(
                        color: AppColors.deepTealLight,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderDark),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            page.icon,
                            color: AppColors.primarySaffronLight,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              page.bodyHi,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    VaakSetuMascot(
                      key: ValueKey('mascot_${page.pose}'),
                      size: 160,
                      pose: page.pose,
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
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

        TactileButton(
          label: isLast ? 'भाषा चुनें / Choose Language' : 'अगला / Next',
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
            child: const Text(
              'पीछे / Back',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          )
        else
          const SizedBox(height: 12),
      ],
    );
  }
}
