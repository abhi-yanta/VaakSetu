import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class HapticService {
  static Future<void> lightTap() async {
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
  }

  static Future<void> selectionClick() async {
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}
  }

  static Future<void> warningFeedback() async {
    try {
      final hasCustomVibrations = await Vibration.hasCustomVibrationsSupport();
      if (hasCustomVibrations) {
        Vibration.vibrate(pattern: [0, 150, 100, 150]);
      } else {
        HapticFeedback.mediumImpact();
      }
    } catch (_) {
      HapticFeedback.mediumImpact();
    }
  }

  static Future<void> dangerFeedback() async {
    try {
      final hasCustomVibrations = await Vibration.hasCustomVibrationsSupport();
      if (hasCustomVibrations) {
        Vibration.vibrate(pattern: [0, 300, 120, 300, 120, 400]);
      } else {
        HapticFeedback.heavyImpact();
      }
    } catch (_) {
      HapticFeedback.heavyImpact();
    }
  }
}
