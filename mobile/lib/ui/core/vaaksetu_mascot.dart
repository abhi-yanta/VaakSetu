import 'package:flutter/material.dart';

enum MascotPose {
  namaste,
  wave,
  point,
  celebrate,
}

/// Standing guide character cutouts (transparent BG, no movement animation).
class VaakSetuMascot extends StatelessWidget {
  final double size;
  final MascotPose pose;

  const VaakSetuMascot({
    super.key,
    this.size = 260,
    this.pose = MascotPose.namaste,
  });

  static String assetForPose(MascotPose pose) {
    switch (pose) {
      case MascotPose.namaste:
        return 'assets/mascot/guide_namaste_final.png';
      case MascotPose.wave:
        return 'assets/mascot/guide_wave_final.png';
      case MascotPose.point:
        return 'assets/mascot/guide_point_final.png';
      case MascotPose.celebrate:
        return 'assets/mascot/guide_celebrate_final.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.2,
      child: Image.asset(
        assetForPose(pose),
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }
}
