import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/features/portfolio/domain/entities/holding.dart';
import 'package:petrimonium/features/portfolio/domain/entities/investment_lot.dart';
import 'package:petrimonium/features/portfolio/domain/entities/investment_type_display.dart';
import 'package:petrimonium/features/portfolio/domain/enums/history_range.dart';
import 'package:petrimonium/features/portfolio/domain/services/wealth_history_calculator.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/shared/formatters.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/shared/performance_badge.dart';

/// Expanded asset detail: mini valuation chart, purchase history and an
/// estimated-income breakdown for a single [Holding]. Fields the brief
/// asked for that this app's data model can't honestly back yet — sector,
/// market cap, fundamentals, a black-box "AI rating" — are intentionally
/// left out rather than faked; see the "Sugestão" line for what's a
/// transparent heuristic instead of an invented score.
class AssetDetailsSheet extends StatelessWidget {
  const AssetDetailsSheet({super.key, required this.holding});

  final Holding holding;

  @override
  Widget build(BuildContext context) {
    final chartPoints = WealthHistoryCalculator.compute(holding.lots, HistoryRange.all);
    final estimatedAnnualIncome = holding.currentValue * holding.type.assumedAnnualYield;
    final overweight = holding.portfolioPercent - holding.type.idealTargetPercent;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        final tokens = context.colors;
        return Container(
          decoration: BoxDecoration(
            color: tokens.surfaceElevated,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: tokens.divider, borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(holding.type.icon, color: holding.type.color, size: 26),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(holding.ticker, style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
                      Text(holding.type.label, style: TextStyle(color: tokens.textSecondary, fontSize: 12)),
                    ],
                  ),
                  const Spacer(),
                  PerformanceBadge(percent: holding.gainPercent),
                ],
              ),
              const SizedBox(height: 20),
              if (chartPoints.length >= 2)
                SizedBox(
                  height: 140,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineTouchData: const LineTouchData(enabled: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: [for (var i = 0; i < chartPoints.length; i++) FlSpot(i.toDouble(), chartPoints[i].portfolioValue)],
                          isCurved: true,
                          color: holding.type.color,
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(show: true, color: holding.type.color.withValues(alpha: 0.15)),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              _statsGrid(context),
              const SizedBox(height: 20),
              _sectionTitle(context, 'Renda Passiva Estimada'),
              const SizedBox(height: 8),
              _infoTile(
                context: context,
                icon: Icons.paid_outlined,
                label: 'Estimativa anual (${(holding.type.assumedAnnualYield * 100).toStringAsFixed(1)}% a.a.)',
                value: PortfolioFormatters.currency(estimatedAnnualIncome),
                color: AppColors.goldenBorder,
              ),
              const SizedBox(height: 20),
              _sectionTitle(context, 'Sugestão de Alocação'),
              const SizedBox(height: 8),
              _infoTile(
                context: context,
                icon: overweight > 0 ? Icons.arrow_circle_up : Icons.arrow_circle_down,
                label: overweight.abs() <= 5
                    ? 'Alinhado com a meta da categoria (${holding.type.idealTargetPercent.toStringAsFixed(0)}%).'
                    : overweight > 0
                        ? 'Categoria acima da meta sugerida (${holding.type.idealTargetPercent.toStringAsFixed(0)}%).'
                        : 'Categoria abaixo da meta sugerida (${holding.type.idealTargetPercent.toStringAsFixed(0)}%).',
                value: '${holding.portfolioPercent.toStringAsFixed(0)}%',
                color: overweight.abs() <= 5 ? tokens.success : tokens.warning,
              ),
              const SizedBox(height: 20),
              _sectionTitle(context, 'Histórico de Compras'),
              const SizedBox(height: 8),
              for (final lot in holding.lots.reversed) _LotTile(lot: lot),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.neonCyan.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.pets, color: AppColors.neonCyan, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'O valor deste ativo contribui diretamente para o patrimônio que impulsiona a evolução do seu companheiro.',
                        style: TextStyle(color: tokens.textSecondary, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(BuildContext context, String text) =>
      Text(text, style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13));

  Widget _statsGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _stat(context, 'Investido', PortfolioFormatters.currency(holding.investedValue, showCents: false))),
        Expanded(child: _stat(context, 'Atual', PortfolioFormatters.currency(holding.currentValue, showCents: false))),
        Expanded(child: _stat(context, 'Preço Médio', PortfolioFormatters.currency(holding.averagePrice))),
        Expanded(child: _stat(context, 'Preço Atual', PortfolioFormatters.currency(holding.currentPrice))),
      ],
    );
  }

  Widget _stat(BuildContext context, String label, String value) {
    final tokens = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: tokens.textSecondary, fontSize: 10)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }

  Widget _infoTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: TextStyle(color: context.colors.textSecondary, fontSize: 11))),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}

class _LotTile extends StatelessWidget {
  const _LotTile({required this.lot});

  final InvestmentLot lot;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(Icons.shopping_cart_outlined, size: 14, color: tokens.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              PortfolioFormatters.date(lot.purchaseDate),
              style: TextStyle(color: tokens.textSecondary, fontSize: 11),
            ),
          ),
          Text(
            '${lot.quantity.toStringAsFixed(lot.quantity.truncateToDouble() == lot.quantity ? 0 : 2)} un · ${PortfolioFormatters.currency(lot.purchasePrice)}',
            style: TextStyle(color: tokens.textPrimary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
