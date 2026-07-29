import 'package:flutter/material.dart';
import 'package:petapp_mobile/core/constants/app_colors.dart';
import 'package:petapp_mobile/features/portfolio/domain/entities/achievement.dart';

class AchievementCardWidget extends StatelessWidget {
  const AchievementCardWidget({super.key, required this.achievement});

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final color = achievement.unlocked ? AppColors.goldenBorder : Colors.white24;

    return Container(
      width: 108,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: achievement.unlocked ? AppColors.goldenBorder.withValues(alpha: 0.1) : AppColors.spaceDark.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: achievement.unlocked ? 0.5 : 0.15)),
        boxShadow: achievement.unlocked
            ? [BoxShadow(color: AppColors.goldenBorder.withValues(alpha: 0.25), blurRadius: 10, spreadRadius: 1)]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            achievement.unlocked ? achievement.icon : Icons.lock_outline,
            color: achievement.unlocked ? AppColors.goldenBorder : Colors.white38,
            size: 26,
          ),
          const SizedBox(height: 8),
          Text(
            achievement.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: achievement.unlocked ? Colors.white : Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '+${achievement.xpReward} XP',
            style: TextStyle(color: achievement.unlocked ? AppColors.goldenBorder : Colors.white24, fontSize: 9),
          ),
        ],
      ),
    );
  }
}
