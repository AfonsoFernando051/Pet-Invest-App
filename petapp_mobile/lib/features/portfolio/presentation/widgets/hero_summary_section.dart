import 'package:flutter/material.dart';
import 'package:petapp_mobile/core/constants/app_colors.dart';
import 'package:petapp_mobile/features/portfolio/presentation/controllers/portfolio_controller.dart';
import 'package:petapp_mobile/features/portfolio/presentation/widgets/portfolio_summary_card.dart';

/// The "Hero Portfolio Summary" — a horizontally-scrolling row of premium
/// stat cards giving an instant read on value, profit, income and
/// performance across multiple timeframes.
class HeroSummarySection extends StatelessWidget {
  const HeroSummarySection({super.key, required this.controller});

  final PortfolioController controller;

  @override
  Widget build(BuildContext context) {
    final s = controller.summary;
    final recentValues = controller.chartPoints.length >= 2
        ? controller.chartPoints.map((p) => p.portfolioValue).toList()
        : null;
    final recentProfit = controller.chartPoints.length >= 2
        ? controller.chartPoints.map((p) => p.profit).toList()
        : null;

    return SizedBox(
      height: 138,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        children: [
          PortfolioSummaryCard(
            title: 'Valor Total',
            icon: Icons.account_balance_wallet,
            value: s.currentValue,
            sparkline: recentValues,
            accentColor: AppColors.neonCyan,
          ),
          const SizedBox(width: 10),
          PortfolioSummaryCard(
            title: 'Capital Investido',
            icon: Icons.savings_outlined,
            value: s.investedCapital,
            subtitle: '${s.totalAssets} ativos',
            accentColor: AppColors.neonPurple,
          ),
          const SizedBox(width: 10),
          PortfolioSummaryCard(
            title: 'Lucro Total',
            icon: Icons.trending_up,
            value: s.totalGain,
            percent: s.totalGainPercent,
            sparkline: recentProfit,
            accentColor: s.totalGain >= 0 ? AppColors.positiveGreen : AppColors.negativeRed,
          ),
          const SizedBox(width: 10),
          PortfolioSummaryCard(
            title: 'Renda Passiva (est.)',
            icon: Icons.paid_outlined,
            value: controller.passiveIncome.annualEstimate,
            subtitle: 'ao ano · estimado',
            accentColor: AppColors.goldenBorder,
          ),
          const SizedBox(width: 10),
          PortfolioSummaryCard(
            title: 'Resultado Hoje',
            icon: Icons.today,
            value: controller.todayChangeValue,
            percent: controller.todayChangePercent,
            accentColor: controller.todayChangeValue >= 0 ? AppColors.positiveGreen : AppColors.negativeRed,
          ),
          const SizedBox(width: 10),
          PortfolioSummaryCard(
            title: 'Desempenho Mensal',
            icon: Icons.calendar_view_month,
            value: controller.monthlyChangeValue,
            percent: controller.monthlyChangePercent,
            accentColor: controller.monthlyChangeValue >= 0 ? AppColors.positiveGreen : AppColors.negativeRed,
          ),
          const SizedBox(width: 10),
          PortfolioSummaryCard(
            title: 'Desempenho Anual',
            icon: Icons.calendar_today,
            value: controller.annualChangeValue,
            percent: controller.annualChangePercent,
            accentColor: controller.annualChangeValue >= 0 ? AppColors.positiveGreen : AppColors.negativeRed,
          ),
          const SizedBox(width: 10),
          PortfolioSummaryCard(
            title: 'Retorno Total',
            icon: Icons.emoji_events_outlined,
            value: s.currentValue - s.investedCapital,
            percent: s.totalGainPercent,
            accentColor: AppColors.neonBlue,
          ),
        ],
      ),
    );
  }
}
