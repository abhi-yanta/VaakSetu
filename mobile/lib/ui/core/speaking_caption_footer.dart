import 'package:flutter/material.dart';

import '../../data/services/tts_service.dart';
import 'app_colors.dart';

/// YouTube Shorts–style speaking captions in the app footer.
///
/// - Large bold words, current word highlighted (saffron)
/// - Solid dark pill so text stays readable
/// - [IgnorePointer] so captions never steal taps
class SpeakingCaptionFooter extends StatelessWidget {
  final TtsService ttsService;
  /// When false (e.g. scanner), hide the idle brand strip entirely.
  final bool showIdleBrand;

  const SpeakingCaptionFooter({
    super.key,
    required this.ttsService,
    this.showIdleBrand = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ttsService,
      builder: (context, _) {
        // Only show karaoke once captions are armed (audio/TTS actually started).
        final playing = ttsService.hasActiveCaption;
        final bottomInset = MediaQuery.paddingOf(context).bottom;

        if (!playing && !showIdleBrand) {
          return SizedBox(height: bottomInset > 0 ? bottomInset * 0.25 : 0);
        }

        return IgnorePointer(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              14,
              playing ? 8 : 6,
              14,
              8 + (bottomInset > 0 ? 4 : 0),
            ),
            color: playing ? const Color(0xF20B1220) : AppColors.surfaceDarkElevated,
            child: playing ? _buildKaraoke(ttsService) : _buildIdleBrand(),
          ),
        );
      },
    );
  }

  Widget _buildIdleBrand() {
    return SizedBox(
      height: 24,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/brand/mark.png',
              width: 16,
              height: 16,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
            const SizedBox(width: 6),
            const Text(
              'VaakSetu • AI Document Assistant',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKaraoke(TtsService tts) {
    final tokens = tts.captionTokens;
    final active = tts.captionActiveIndex.clamp(0, tokens.length - 1);

    // Wider window so Hindi phrases feel complete (Shorts-like).
    const window = 10;
    var start = (active - 3).clamp(0, tokens.length);
    var end = (start + window).clamp(0, tokens.length);
    if (end == tokens.length && end - start < window) {
      start = (end - window).clamp(0, tokens.length);
    }

    final visible = <InlineSpan>[];
    for (var i = start; i < end; i++) {
      final isActive = i == active;
      final isPast = i < active;
      visible.add(
        TextSpan(
          text: '${tokens[i]}${i < end - 1 ? ' ' : ''}',
          style: TextStyle(
            color: isActive
                ? const Color(0xFFFFB74D) // bright saffron — pops on dark
                : isPast
                    ? Colors.white60
                    : Colors.white,
            fontSize: isActive ? 20 : 16,
            fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
            height: 1.3,
            letterSpacing: 0.15,
            shadows: const [
              Shadow(
                color: Colors.black87,
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF000000),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primarySaffron.withValues(alpha: 0.55),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text.rich(
        TextSpan(children: visible),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.fade,
      ),
    );
  }
}
