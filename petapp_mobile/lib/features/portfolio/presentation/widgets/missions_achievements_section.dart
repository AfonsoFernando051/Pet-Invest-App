import 'package:flutter/material.dart';
import 'package:petapp_mobile/core/constants/app_colors.dart';
import 'package:petapp_mobile/core/widgets/glass_card.dart';
import 'package:petapp_mobile/features/portfolio/domain/entities/achievement.dart';
import 'package:petapp_mobile/features/portfolio/domain/entities/mission.dart';
import 'package:petapp_mobile/features/portfolio/presentation/widgets/achievement_card_widget.dart';
import 'package:petapp_mobile/features/portfolio/presentation/widgets/mission_card_widget.dart';
import 'package:petapp_mobile/features/portfolio/presentation/widgets/shared/section_label.dart';

class MissionsAchievementsSection extends StatelessWidget {
  const MissionsAchievementsSection({super.key, required this.missions, required this.achievements});

  final List<Mission> missions;
  final List<Achievement> achievements;

  @override
  Widget build(BuildContext context) {
    final unlockedCount = achievements.where((a) => a.unlocked).length;

    return GlassCard(
      backgroundColor: AppColors.spaceDark.withValues(alpha: 0.58),
      borderColor: AppColors.goldenBorder.withValues(alpha: 0.3),
      borderRadius: 20,
      borderWidth: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel('MISSÕES'),
            const SizedBox(height: 10),
            for (final mission in missions) MissionCardWidget(mission: mission),
            const SizedBox(height: 8),
            SectionLabel('CONQUISTAS · $unlockedCount/${achievements.length}'),
            const SizedBox(height: 10),
            SizedBox(
              height: 118,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: achievements.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) => AchievementCardWidget(achievement: achievements[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
