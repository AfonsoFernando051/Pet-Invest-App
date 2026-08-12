import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/features/portfolio/domain/entities/mission.dart';

class MissionCardWidget extends StatelessWidget {
  const MissionCardWidget({super.key, required this.mission});

  final Mission mission;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final color = mission.isComplete ? tokens.success : AppColors.neonCyan;

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: tokens.surface.withValues(alpha: context.isDarkMode ? 0.5 : 0.94),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
            child: Icon(
              mission.isComplete ? Icons.check_circle : mission.icon,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mission.title, style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Stack(
                    children: [
                      Container(height: 5, color: tokens.textTertiary.withValues(alpha: 0.18)),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: mission.progress),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) => FractionallySizedBox(
                          widthFactor: value,
                          child: Container(height: 5, color: color),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text('+${mission.xpReward} XP', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
        ],
      ),
    );
  }
}
