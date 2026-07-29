import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:petapp_mobile/core/constants/app_colors.dart';
import 'package:petapp_mobile/features/portfolio/domain/entities/holding.dart';
import 'package:petapp_mobile/features/portfolio/domain/entities/investment_lot.dart';
import 'package:petapp_mobile/features/portfolio/domain/entities/investment_type_display.dart';
import 'package:petapp_mobile/features/portfolio/domain/enums/history_range.dart';
import 'package:petapp_mobile/features/portfolio/domain/services/wealth_history_calculator.dart';
import 'package:petapp_mobile/features/portfolio/presentation/widgets/shared/formatters.dart';
import 'package:petapp_mobile/features/portfolio/presentation/widgets/shared/performance_badge.dart';

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
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.spaceBlue,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4)),
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
                      Text(holding.ticker, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      Text(holding.type.label, style: TextStyle(color: AppColors.subtleText, fontSize: 12)),
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
              _statsGrid(),
              const SizedBox(height: 20),
              _sectionTitle('Renda Passiva Estimada'),
              const SizedBox(height: 8),
              _infoTile(
                icon: Icons.paid_outlined,
                label: 'Estimativa anual (${(holding.type.assumedAnnualYield * 100).toStringAsFixed(1)}% a.a.)',
                value: PortfolioFormatters.currency(estimatedAnnualIncome),
                color: AppColors.goldenBorder,
              ),
              const SizedBox(height: 20),
              _sectionTitle('Sugestão de Alocação'),
              const SizedBox(height: 8),
              _infoTile(
                icon: overweight > 0 ? Icons.arrow_circle_up : Icons.arrow_circle_down,
                label: overweight.abs() <= 5
                    ? 'Alinhado com a meta da categoria (${holding.type.idealTargetPercent.toStringAsFixed(0)}%).'
                    : overweight > 0
                        ? 'Categoria acima da meta sugerida (${holding.type.idealTargetPercent.toStringAsFixed(0)}%).'
                        : 'Categoria abaixo da meta sugerida (${holding.type.idealTargetPercent.toStringAsFixed(0)}%).',
                value: '${holding.portfolioPercent.toStringAsFixed(0)}%',
                color: overweight.abs() <= 5 ? AppColors.positiveGreen : AppColors.warningAmber,
              ),
              const SizedBox(height: 20),
              _sectionTitle('Histórico de Compras'),
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
                        style: TextStyle(color: AppColors.subtleText, fontSize: 11),
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

  Widget _sectionTitle(String text) =>
      Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13));

  Widget _statsGrid() {
    return Row(
      children: [
        Expanded(child: _stat('Investido', PortfolioFormatters.currency(holding.investedValue, showCents: false))),
        Expanded(child: _stat('Atual', PortfolioFormatters.currency(holding.currentValue, showCents: false))),
        Expanded(child: _stat('Preço Médio', PortfolioFormatters.currency(holding.averagePrice))),
        Expanded(child: _stat('Preço Atual', PortfolioFormatters.currency(holding.currentPrice))),
      ],
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppColors.subtleText, fontSize: 10)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }

  Widget _infoTile({required IconData icon, required String label, required String value, required Color color}) {
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
          Expanded(child: Text(label, style: TextStyle(color: AppColors.subtleText, fontSize: 11))),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.shopping_cart_outlined, size: 14, color: AppColors.subtleText),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              PortfolioFormatters.date(lot.purchaseDate),
              style: TextStyle(color: AppColors.subtleText, fontSize: 11),
            ),
          ),
          Text(
            '${lot.quantity.toStringAsFixed(lot.quantity.truncateToDouble() == lot.quantity ? 0 : 2)} un · ${PortfolioFormatters.currency(lot.purchasePrice)}',
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
