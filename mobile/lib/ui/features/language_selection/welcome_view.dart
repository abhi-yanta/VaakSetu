import 'package:flutter/material.dart';
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
            // Logo Badge
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primarySaffron.withOpacity(0.4),
                      blurRadius: 28,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/icon/app_icon.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Titles
            const Text(
              'वाक् सेतु',
              style: TextStyle(
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'VaakSetu — The Voice Bridge',
              style: TextStyle(
                color: AppColors.primarySaffronLight,
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
