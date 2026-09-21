import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'app_colors.dart';

class WaveVisualizer extends StatefulWidget {
  final bool isPlaying;
  final double height;
  final Color? barColor;

  const WaveVisualizer({
    super.key,
    required this.isPlaying,
    this.height = 70.0,
    this.barColor,
  });

  @override
  State<WaveVisualizer> createState() => _WaveVisualizerState();
}

class _WaveVisualizerState extends State<WaveVisualizer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isPlaying ? AppColors.primarySaffronLight.withOpacity(0.5) : AppColors.borderDark,
          width: 1.5,
        ),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _WavePainter(
              animationValue: _controller.value,
              isPlaying: widget.isPlaying,
              barColor: widget.barColor ?? AppColors.primarySaffron,
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double animationValue;
  final bool isPlaying;
  final Color barColor;

  _WavePainter({
    required this.animationValue,
    required this.isPlaying,
    required this.barColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const int barCount = 28;
    final double barWidth = (size.width - ((barCount - 1) * 3)) / barCount;
    final double centerY = size.height / 2;

    final paint = Paint()
      ..color = isPlaying ? barColor : AppColors.textMuted.withOpacity(0.4)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    for (int i = 0; i < barCount; i++) {
      final double x = i * (barWidth + 3);
      double barHeight;

      if (isPlaying) {
        // Multi-frequency wave calculation for natural speech visualization
        final double wave1 = math.sin((animationValue * 2 * math.pi) + (i * 0.35));
        final double wave2 = math.cos((animationValue * 4 * math.pi) + (i * 0.2));
        final double combined = (wave1 + wave2).abs() / 2.0;
        barHeight = math.max(6.0, combined * (size.height * 0.85));
      } else {
        barHeight = 4.0;
      }

      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x + (barWidth / 2), centerY),
          width: barWidth,
          height: barHeight,
        ),
        const Radius.circular(2.0),
      );

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || oldDelegate.isPlaying != isPlaying;
  }
}
