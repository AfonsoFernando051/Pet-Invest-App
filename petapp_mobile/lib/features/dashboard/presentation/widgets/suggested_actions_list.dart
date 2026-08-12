import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/onboarding_screen.dart';

/// Home's "always something meaningful to do" list — shown alongside (or
/// instead of) portfolio data so a user who skipped portfolio setup still
/// has a clear next step, per the onboarding redesign's placeholder spec.
class SuggestedActionsList extends StatelessWidget {
  const SuggestedActionsList({
    super.key,
    required this.onLearnDividends,
    required this.onOpenAcademy,
    required this.showInvestorProfileAction,
  });

  /// Switches Home to the Proventos (passive income / dividends) tab.
  final VoidCallback onLearnDividends;

  /// Opens the Academy — the "Complete a Lesson" and "First Quiz" entries
  /// both lead here today, since Academy doesn't yet have a distinct quiz-only
  /// entry point (see `docs/ACADEMY_ENGINE.md`).
  final VoidCallback onOpenAcademy;

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
      (Icons.menu_book_outlined, AppStrings.suggestedActionCompleteLesson, () {
        HapticFeedback.selectionClick();
        onOpenAcademy();
      }),
      (Icons.flag_outlined, AppStrings.suggestedActionTodayMission, () => _comingSoon(context)),
      (Icons.payments_outlined, AppStrings.suggestedActionLearnDividends, () {
        HapticFeedback.selectionClick();
        onLearnDividends();
      }),
      (Icons.quiz_outlined, AppStrings.suggestedActionFirstQuiz, () {
        HapticFeedback.selectionClick();
        onOpenAcademy();
      }),
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
          _buildTile(context, icon, labelKey, onTap),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildTile(BuildContext context, IconData icon, String labelKey, VoidCallback onTap) {
    final tokens = context.colors;
    return GlassCard(
      backgroundColor: tokens.surface.withValues(alpha: context.isDarkMode ? 0.4 : 0.94),
      borderColor: tokens.border,
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
                    style: TextStyle(color: tokens.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                Icon(Icons.chevron_right, color: tokens.textTertiary, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
