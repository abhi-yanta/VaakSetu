import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// AnimatedLogo displays the VaakSetu app logo with smooth pulse/glow animations
/// and an orbiting scanner ring during loading delays.
class AnimatedLogo extends StatefulWidget {
  final double size;
  final bool isLoading;

  const AnimatedLogo({
    super.key,
    this.size = 110,
    this.isLoading = false,
  });

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo> with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _rotationController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Pulse / Breathing animation controller
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Rotation controller for loading ring
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    if (widget.isLoading) {
      _rotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !_rotationController.isAnimating) {
      _rotationController.repeat();
    } else if (!widget.isLoading && _rotationController.isAnimating) {
      _rotationController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logoWidget = AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = _scaleAnimation.value;
        final glowOpacity = (scale - 0.96) / 0.1 * 0.4 + 0.2; // 0.2 to 0.6

        return Transform.scale(
          scale: scale,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.size * 0.24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primarySaffron.withOpacity(glowOpacity),
                  blurRadius: widget.size * 0.3,
                  spreadRadius: widget.size * 0.05,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.size * 0.24),
              child: Image.asset(
                'assets/icon/app_icon.png',
                width: widget.size,
                height: widget.size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.primarySaffron,
                  child: Icon(Icons.shield_rounded, color: Colors.white, size: widget.size * 0.5),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (!widget.isLoading) {
      return logoWidget;
    }

    final outerRingSize = widget.size + 36;
    return SizedBox(
      width: outerRingSize,
      height: outerRingSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Rotating Glowing Scanner Ring
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationController.value * 2 * math.pi,
                child: SizedBox(
                  width: outerRingSize,
                  height: outerRingSize,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.5,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primarySaffronLight),
                    backgroundColor: AppColors.primarySaffron.withOpacity(0.15),
                  ),
                ),
              );
            },
          ),
          // Center Pulsing Logo
          logoWidget,
        ],
      ),
    );
  }
}
