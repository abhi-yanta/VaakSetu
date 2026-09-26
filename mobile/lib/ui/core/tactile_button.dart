import 'package:flutter/material.dart';
import '../../data/services/haptic_service.dart';
import 'app_colors.dart';

enum TactileButtonStyle {
  primary,
  secondary,
  safe,
  warning,
  danger,
}

class TactileButton extends StatelessWidget {
  final String label;
  final Widget? icon;
  final VoidCallback onPressed;
  final TactileButtonStyle style;
  final bool isFullWidth;
  final double height;
  final double fontSize;
  final EdgeInsetsGeometry? contentPadding;
  final double iconSpacing;

  const TactileButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.style = TactileButtonStyle.primary,
    this.isFullWidth = true,
    this.height = 64.0,
    this.fontSize = 18.0,
    this.contentPadding,
    this.iconSpacing = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor = Colors.white;
    Color borderColor = Colors.transparent;

    switch (style) {
      case TactileButtonStyle.primary:
        bgColor = AppColors.primarySaffron;
        break;
      case TactileButtonStyle.secondary:
        bgColor = AppColors.surfaceDarkElevated;
        borderColor = AppColors.borderDark;
        textColor = AppColors.textPrimary;
        break;
      case TactileButtonStyle.safe:
        bgColor = AppColors.safeGreen;
        break;
      case TactileButtonStyle.warning:
        bgColor = AppColors.warningYellow;
        textColor = Colors.black;
        break;
      case TactileButtonStyle.danger:
        bgColor = AppColors.dangerRed;
        break;
    }

    final padding = contentPadding ??
        EdgeInsets.symmetric(
          horizontal: height <= 52 ? 8 : 20,
          vertical: height <= 52 ? 6 : 12,
        );

    final button = Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(16),
      elevation: 4,
      shadowColor: bgColor.withOpacity(0.4),
      child: InkWell(
        onTap: () {
          HapticService.lightTap();
          onPressed();
        },
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.white.withOpacity(0.2),
        child: Container(
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            children: [
              if (icon != null) ...[
                icon!,
                SizedBox(width: iconSpacing),
              ],
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                    height: 1.15,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return isFullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}
