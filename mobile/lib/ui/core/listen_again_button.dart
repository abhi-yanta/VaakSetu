import 'package:flutter/material.dart';

import '../../domain/models/localized_content.dart';
import 'app_colors.dart';
import 'tactile_button.dart';

/// Labeled secondary control to re-trigger TTS for the current guided prompt.
class ListenAgainButton extends StatelessWidget {
  final String langCode;
  final VoidCallback onPressed;
  final bool isFullWidth;
  final double height;
  final double fontSize;
  final TactileButtonStyle style;

  const ListenAgainButton({
    super.key,
    required this.langCode,
    required this.onPressed,
    this.isFullWidth = true,
    this.height = 56.0,
    this.fontSize = 16.0,
    this.style = TactileButtonStyle.secondary,
  });

  @override
  Widget build(BuildContext context) {
    final label = LocalizedContent.get(langCode, 'listen_again');
    final iconColor =
        style == TactileButtonStyle.secondary ? AppColors.textPrimary : Colors.white;

    return TactileButton(
      label: label,
      icon: Icon(Icons.volume_up_rounded, color: iconColor, size: 24),
      style: style,
      isFullWidth: isFullWidth,
      height: height,
      fontSize: fontSize,
      onPressed: onPressed,
    );
  }
}
