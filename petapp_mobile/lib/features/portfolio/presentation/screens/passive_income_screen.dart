import 'package:flutter/material.dart';
import 'package:petapp_mobile/core/constants/app_colors.dart';
import 'package:petapp_mobile/features/portfolio/presentation/controllers/portfolio_controller.dart';
import 'package:petapp_mobile/features/portfolio/presentation/widgets/passive_income_card.dart';
import 'package:petapp_mobile/features/portfolio/presentation/widgets/shared/error_banner.dart';
import 'package:petapp_mobile/features/portfolio/presentation/widgets/shared/section_label.dart';

/// The "Proventos" (Passive Income) tab — its own dedicated home, no longer
/// folded into the Home dashboard. [controller] is owned and loaded by
/// `DashboardScreen` and shared across tabs.
class PassiveIncomeScreen extends StatelessWidget {
  const PassiveIncomeScreen({super.key, required this.controller});

  final PortfolioController controller;

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
            const SectionLabel('RENDA PASSIVA'),
            const SizedBox(height: 10),
            PassiveIncomeCard(estimate: controller.passiveIncome),
          ],
        ),
      ),
    );
  }
}
