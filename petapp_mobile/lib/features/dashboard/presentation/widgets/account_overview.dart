import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';

class AccountOverview extends StatelessWidget {
  const AccountOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      backgroundColor: AppColors.spaceDark.withValues(alpha: 0.6),
      borderColor: AppColors.neonCyan.withValues(alpha: 0.3),
      borderRadius: 16,
      borderWidth: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: Text('Visão Geral da Conta', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
            const SizedBox(height: 12),
            const Text('Patrimônio Total: R\$ 15,200.00', style: TextStyle(color: Colors.white, fontSize: 12)),
            const Text('Lucro do Dia: +R\$ 180.00 (+1.2%)', style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  minX: 0, maxX: 6, minY: 0, maxY: 6,
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [FlSpot(0, 1), FlSpot(1, 3), FlSpot(2, 2.5), FlSpot(3, 4), FlSpot(4, 3.5), FlSpot(5, 5), FlSpot(6, 4.5)],
                      isCurved: false,
                      color: AppColors.neonCyan,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: const [FlSpot(0, 1.5), FlSpot(1, 2.5), FlSpot(2, 1.5), FlSpot(3, 3), FlSpot(4, 2), FlSpot(5, 3.5), FlSpot(6, 3.5)],
                      isCurved: false,
                      color: const Color(0xFFFF007F),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegend(AppColors.neonCyan, 'Portfolio'),
                const SizedBox(width: 16),
                _buildLegend(const Color(0xFFFF007F), 'IBOV'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(width: 16, height: 4, color: color),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }
}
