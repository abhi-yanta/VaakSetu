import 'package:flutter/material.dart';
import '../../../data/services/haptic_service.dart';
import '../../../domain/models/localized_content.dart';
import '../../core/app_colors.dart';

/// Post-language chooser: Legal Document Scanner vs Form Field Guide.
class ModeChooserView extends StatelessWidget {
  final String selectedLang;
  final VoidCallback onScannerSelected;
  final VoidCallback onFormGuideSelected;
  final VoidCallback onBack;

  const ModeChooserView({
    super.key,
    required this.selectedLang,
    required this.onScannerSelected,
    required this.onFormGuideSelected,
    required this.onBack,
  });

  String _t(String key) => LocalizedContent.get(selectedLang, key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  HapticService.lightTap();
                  onBack();
                },
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textSecondary),
                tooltip: _t('back'),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _t('mode_title'),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              _ModeOptionCard(
                icon: Icons.document_scanner_rounded,
                accent: AppColors.primarySaffron,
                title: _t('mode_scanner_title'),
                subtitle: _t('mode_scanner_sub'),
                onTap: () {
                  HapticService.selectionClick();
                  onScannerSelected();
                },
              ),
              const SizedBox(height: 16),
              _ModeOptionCard(
                icon: Icons.edit_note_rounded,
                accent: AppColors.deepTealLight,
                title: _t('mode_form_title'),
                subtitle: _t('mode_form_sub'),
                onTap: () {
                  HapticService.selectionClick();
                  onFormGuideSelected();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ModeOptionCard extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ModeOptionCard({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceDark,
      borderRadius: BorderRadius.circular(20),
      elevation: 4,
      shadowColor: Colors.black54,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: accent.withValues(alpha: 0.25),
        child: Container(
          constraints: const BoxConstraints(minHeight: 148),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accent.withValues(alpha: 0.55), width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: 0.18),
                  border: Border.all(color: accent.withValues(alpha: 0.5), width: 1.5),
                ),
                child: Icon(icon, color: accent, size: 32),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: accent, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}
