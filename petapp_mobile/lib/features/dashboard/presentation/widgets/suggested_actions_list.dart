import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petapp_mobile/core/constants/app_colors.dart';
import 'package:petapp_mobile/core/constants/app_strings.dart';
import 'package:petapp_mobile/core/utils/translator.dart';
import 'package:petapp_mobile/core/widgets/glass_card.dart';
import 'package:petapp_mobile/features/onboarding/presentation/screens/onboarding_screen.dart';

/// Home's "always something meaningful to do" list — shown alongside (or
/// instead of) portfolio data so a user who skipped portfolio setup still
/// has a clear next step, per the onboarding redesign's placeholder spec.
class SuggestedActionsList extends StatelessWidget {
  const SuggestedActionsList({
    super.key,
    required this.onLearnDividends,
    required this.showInvestorProfileAction,
  });

  /// Switches Home to the Proventos (passive income / dividends) tab.
  final VoidCallback onLearnDividends;

  /// Whether the risk-assessment questionnaire is still unanswered — that
  /// step is optional now, so it only appears here if not already done.
  final bool showInvestorProfileAction;

  void _comingSoon(BuildContext context) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(Translator.translate(AppStrings.comingSoonSnack))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final actions = <(IconData, String, VoidCallback)>[
      (Icons.menu_book_outlined, AppStrings.suggestedActionCompleteLesson, () => _comingSoon(context)),
      (Icons.flag_outlined, AppStrings.suggestedActionTodayMission, () => _comingSoon(context)),
      (Icons.payments_outlined, AppStrings.suggestedActionLearnDividends, () {
        HapticFeedback.selectionClick();
        onLearnDividends();
      }),
      (Icons.quiz_outlined, AppStrings.suggestedActionFirstQuiz, () => _comingSoon(context)),
      if (showInvestorProfileAction)
        (Icons.assignment_outlined, AppStrings.suggestedActionInvestorProfile, () {
          HapticFeedback.selectionClick();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          );
        }),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (icon, labelKey, onTap) in actions) ...[
          _buildTile(icon, labelKey, onTap),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildTile(IconData icon, String labelKey, VoidCallback onTap) {
    return GlassCard(
      backgroundColor: AppColors.spaceDark.withValues(alpha: 0.4),
      borderColor: Colors.white.withValues(alpha: 0.1),
      borderRadius: 16,
      borderWidth: 1,
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: AppColors.neonCyan, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    Translator.translate(labelKey),
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white38, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
