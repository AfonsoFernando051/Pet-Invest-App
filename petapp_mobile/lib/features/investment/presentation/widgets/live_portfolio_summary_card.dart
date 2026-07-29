import 'package:flutter/material.dart';
import 'package:petapp_mobile/core/constants/app_colors.dart';
import 'package:petapp_mobile/core/widgets/glass_card.dart';
import 'package:petapp_mobile/features/portfolio/domain/entities/portfolio_stats.dart';
import 'package:petapp_mobile/features/portfolio/domain/services/achievement_catalog.dart';
import 'package:petapp_mobile/features/portfolio/domain/services/mission_catalog.dart';
import 'package:petapp_mobile/features/portfolio/domain/services/passive_income_estimator.dart';
import 'package:petapp_mobile/features/portfolio/presentation/widgets/shared/formatters.dart';

/// Instant, always-visible feedback after every asset add — reuses the same
/// domain services as the real Dashboard (`PassiveIncomeEstimator`,
/// `AchievementCatalog`, `MissionCatalog`) so every figure shown here is a
/// real computed preview, not a separate onboarding-only estimate.
class LivePortfolioSummaryCard extends StatelessWidget {
  const LivePortfolioSummaryCard({super.key, required this.stats, required this.alreadyUnlockedIds});

  final PortfolioStats stats;
  final Set<String> alreadyUnlockedIds;

  @override
  Widget build(BuildContext context) {
    final hasAssets = stats.hasHoldings;
    final income = PassiveIncomeEstimator.estimate(stats);
    final qualified = AchievementCatalog.qualifiedIds(stats);
    final newlyQualified = qualified.difference(alreadyUnlockedIds);
    final xp = AchievementCatalog.totalXpFor(newlyQualified);
    final missions = MissionCatalog.evaluate(stats);
    final firstMission = missions.firstWhere((m) => m.isComplete, orElse: () => missions.first);

    return GlassCard(
      backgroundColor: AppColors.spaceDark.withValues(alpha: 0.55),
      borderColor: AppColors.goldenBorder.withValues(alpha: 0.3),
      borderRadius: 20,
      borderWidth: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Portfólio', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _stat('Ativos', '${stats.summary.totalAssets}', AppColors.neonCyan)),
                Expanded(child: _stat('Valor', PortfolioFormatters.compactCurrency(stats.summary.currentValue), AppColors.neonCyan)),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _stat(
                    'Renda Passiva Est.',
                    hasAssets ? '${PortfolioFormatters.currency(income.monthlyEstimate, showCents: false)}/mês' : '—',
                    AppColors.goldenBorder,
                  ),
                ),
                Expanded(child: _stat('XP Ganho', '+$xp XP', AppColors.neonPink)),
              ],
            ),
            if (hasAssets) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: firstMission.isComplete
                      ? AppColors.positiveGreen.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      firstMission.isComplete ? Icons.check_circle : firstMission.icon,
                      color: firstMission.isComplete ? AppColors.positiveGreen : AppColors.subtleText,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        firstMission.title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: firstMission.isComplete ? AppColors.positiveGreen : AppColors.subtleText,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppColors.subtleText, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}
