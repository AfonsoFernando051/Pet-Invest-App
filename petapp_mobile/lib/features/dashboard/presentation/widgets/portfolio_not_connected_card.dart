import 'package:flutter/material.dart';
import 'package:petapp_mobile/core/constants/app_colors.dart';
import 'package:petapp_mobile/core/constants/app_strings.dart';
import 'package:petapp_mobile/core/utils/translator.dart';
import 'package:petapp_mobile/core/widgets/game_button.dart';
import 'package:petapp_mobile/core/widgets/glass_card.dart';
import 'package:petapp_mobile/features/investment/presentation/screens/portfolio_choice_screen.dart';

/// Home's placeholder when the user skipped (or hasn't yet reached) the
/// portfolio step — the app must stay fully usable without a portfolio, so
/// this replaces the holdings/allocation cards instead of blocking Home.
class PortfolioNotConnectedCard extends StatelessWidget {
  const PortfolioNotConnectedCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      backgroundColor: AppColors.spaceDark.withValues(alpha: 0.5),
      borderColor: AppColors.neonCyan.withValues(alpha: 0.3),
      borderRadius: 24,
      borderWidth: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.neonCyan.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.diamond_outlined, color: AppColors.neonCyan),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Translator.translate(AppStrings.portfolioNotConnectedTitle),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        Translator.translate(AppStrings.portfolioNotConnectedBody),
                        style: const TextStyle(color: AppColors.subtleText, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GameButton(
              label: Translator.translate(AppStrings.connectInvestmentsButton),
              icon: Icons.arrow_forward,
              iconTrailing: true,
              height: 48,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PortfolioChoiceScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
