import 'package:flutter/material.dart';
import '../../domain/models/document_analysis.dart';
import '../../domain/models/localized_content.dart';
import 'app_colors.dart';

class SecurityBadge extends StatelessWidget {
  final DocumentAnalysis analysis;
  final String langCode;

  const SecurityBadge({
    super.key,
    required this.analysis,
    required this.langCode,
  });

  @override
  Widget build(BuildContext context) {
    Color cardBg;
    Color borderColor;
    Color iconColor;
    IconData icon;
    String statusText;

    switch (analysis.severity) {
      case DocumentSeverity.safe:
        cardBg = AppColors.safeGreenBg.withOpacity(0.35);
        borderColor = AppColors.safeGreen;
        iconColor = AppColors.safeGreen;
        icon = Icons.verified_user_rounded;
        statusText = LocalizedContent.get(langCode, 'safe_doc');
        break;
      case DocumentSeverity.warning:
        cardBg = AppColors.warningYellowBg.withOpacity(0.35);
        borderColor = AppColors.warningYellow;
        iconColor = AppColors.warningYellow;
        icon = Icons.warning_amber_rounded;
        statusText = LocalizedContent.get(langCode, 'warning_doc');
        break;
      case DocumentSeverity.danger:
        cardBg = AppColors.dangerRedBg.withOpacity(0.4);
        borderColor = AppColors.dangerRed;
        iconColor = AppColors.dangerRed;
        icon = Icons.gpp_bad_rounded;
        statusText = LocalizedContent.get(langCode, 'danger_doc');
        break;
      case DocumentSeverity.unknown:
        cardBg = const Color(0xFF0C2136).withOpacity(0.6);
        borderColor = const Color(0xFF38BDF8);
        iconColor = const Color(0xFF38BDF8);
        icon = Icons.info_outline_rounded;
        statusText = analysis.category == DocumentCategory.unclear
            ? LocalizedContent.get(langCode, 'unclear_doc')
            : LocalizedContent.get(langCode, 'unrecognized_doc');
        break;
    }

    final categoryKey = analysis.category.key;
    final categoryName = LocalizedContent.get(langCode, categoryKey);
    final categoryLabel = LocalizedContent.get(langCode, 'category');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Icon(icon, color: iconColor, size: 40),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "$categoryLabel: $categoryName",
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.25,
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
