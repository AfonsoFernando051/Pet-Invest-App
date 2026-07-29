import 'package:flutter/material.dart';
import 'package:petapp_mobile/core/constants/app_colors.dart';
import 'package:petapp_mobile/core/constants/app_strings.dart';
import 'package:petapp_mobile/core/utils/translator.dart';
import 'package:petapp_mobile/core/widgets/glass_card.dart';
import 'package:petapp_mobile/features/investment/presentation/screens/portfolio_choice_screen.dart';

/// The pet's gentle, occasional nudge to connect a portfolio after the user
/// skipped that step — paced by `OnboardingStateRepository.
/// shouldShowPortfolioReminder()` so it appears at most once every few
/// sessions, never on every visit. Dismissible; never blocks anything.
class PortfolioReminderBanner extends StatelessWidget {
  const PortfolioReminderBanner({super.key, required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      backgroundColor: AppColors.spaceDark.withValues(alpha: 0.55),
      borderColor: AppColors.neonPink.withValues(alpha: 0.35),
      borderRadius: 20,
      borderWidth: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.favorite, color: AppColors.neonPink, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    Translator.translate(AppStrings.portfolioReminderMessage),
                    style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onDismiss,
                  child: Text(
                    Translator.translate(AppStrings.portfolioReminderDismiss),
                    style: const TextStyle(color: Colors.white54),
                  ),
                ),
                const SizedBox(width: 4),
                TextButton(
                  onPressed: () {
                    onDismiss();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PortfolioChoiceScreen()),
                    );
                  },
                  child: Text(
                    Translator.translate(AppStrings.portfolioReminderCta),
                    style: const TextStyle(color: AppColors.neonCyan, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
