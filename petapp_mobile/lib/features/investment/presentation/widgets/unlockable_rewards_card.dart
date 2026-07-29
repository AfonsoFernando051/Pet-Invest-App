import 'package:flutter/material.dart';
import 'package:petapp_mobile/core/constants/app_colors.dart';
import 'package:petapp_mobile/features/portfolio/domain/entities/portfolio_stats.dart';
import 'package:petapp_mobile/features/portfolio/domain/services/achievement_catalog.dart';

/// The left panel's "what you're about to unlock" checklist. Every item
/// here shares the same unlock condition as the real `first_investment`
/// achievement (having at least one holding) — the +XP figure is pulled
/// from the real `AchievementCatalog` rather than a hardcoded number, so it
/// can never drift out of sync with what actually gets awarded once the
/// user confirms and the Dashboard evaluates achievements for real.
class UnlockableRewardsCard extends StatelessWidget {
  const UnlockableRewardsCard({super.key, required this.stats});

  final PortfolioStats stats;

  @override
  Widget build(BuildContext context) {
    final unlocked = AchievementCatalog.qualifiedIds(stats).contains('first_investment');
    final xp = AchievementCatalog.totalXpFor({'first_investment'});

    final items = [
      'Emblema de Primeiro Investidor',
      '+$xp XP',
      'Missões Diárias',
      'Acompanhamento de Portfólio',
      'Evolução do Pet',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          unlocked ? 'Você desbloqueou:' : 'Adicione seu primeiro ativo para desbloquear:',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 10),
        for (final item in items) _RewardRow(label: item, unlocked: unlocked),
      ],
    );
  }
}

class _RewardRow extends StatelessWidget {
  const _RewardRow({required this.label, required this.unlocked});

  final String label;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final color = unlocked ? AppColors.positiveGreen : Colors.white38;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: unlocked ? AppColors.positiveGreen.withValues(alpha: 0.2) : Colors.transparent,
              border: Border.all(color: color, width: 1.5),
            ),
            child: unlocked ? const Icon(Icons.check, size: 12, color: AppColors.positiveGreen) : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: unlocked ? Colors.white : Colors.white54,
                fontSize: 13,
                fontWeight: unlocked ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
