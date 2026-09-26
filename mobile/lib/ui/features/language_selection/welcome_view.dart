import 'package:flutter/material.dart';
import '../../core/animated_logo.dart';
import '../../core/app_colors.dart';
import '../../core/tactile_button.dart';

class WelcomeView extends StatelessWidget {
  final VoidCallback onStart;

  const WelcomeView({
    super.key,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Logo Badge
            const AnimatedLogo(size: 110),
            const SizedBox(height: 32),

            // Titles
            const Text(
              'वाक् सेतु',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 38,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'VaakSetu — The Voice Bridge',
              style: TextStyle(
                color: AppColors.primarySaffron,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),

            // Description
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderDark, width: 1),
              ),
              child: const Text(
                'सुरक्षित दस्तावेज़ पाठन सहायता।\nशुरू करने के लिए नीचे दिया गया बटन दबाएं।',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),

            // Big Start Button
            TactileButton(
              label: 'यहाँ दबाएं / TAP HERE',
              icon: const Icon(Icons.touch_app_rounded, color: Colors.white, size: 28),
              style: TactileButtonStyle.primary,
              height: 72,
              fontSize: 20,
              onPressed: onStart,
            ),
          ],
        ),
      ),
    );
  }
}
