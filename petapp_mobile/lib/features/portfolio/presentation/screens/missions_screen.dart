import 'package:flutter/material.dart';
import 'package:petapp_mobile/core/constants/app_colors.dart';
import 'package:petapp_mobile/features/pet/presentation/mascot/controllers/mascot_controller.dart';
import 'package:petapp_mobile/features/portfolio/presentation/controllers/portfolio_controller.dart';
import 'package:petapp_mobile/features/portfolio/presentation/widgets/missions_achievements_section.dart';
import 'package:petapp_mobile/features/portfolio/presentation/widgets/rpg_integration_card.dart';
import 'package:petapp_mobile/features/portfolio/presentation/widgets/shared/error_banner.dart';

/// The "Missões" tab — the app's gamification hub: pet evolution/XP/streak
/// plus missions and achievements, no longer folded into the Home dashboard.
/// [controller]/[mascotController] are owned and loaded by `DashboardScreen`
/// and shared across tabs.
class MissionsScreen extends StatelessWidget {
  const MissionsScreen({super.key, required this.controller, required this.mascotController});

  final PortfolioController controller;
  final MascotController mascotController;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading && controller.holdings.isEmpty && controller.error == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.neonCyan));
    }

    return RefreshIndicator(
      color: AppColors.neonCyan,
      backgroundColor: AppColors.spaceBlue,
      onRefresh: controller.refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (controller.error != null) ...[
              ErrorBanner(onRetry: controller.refresh),
              const SizedBox(height: 12),
            ],
            RpgIntegrationCard(controller: mascotController, stats: controller.stats),
            const SizedBox(height: 16),
            MissionsAchievementsSection(missions: controller.missions, achievements: controller.achievements),
          ],
        ),
      ),
    );
  }
}
