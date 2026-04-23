import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';

class RpgAttributes extends StatelessWidget {
  const RpgAttributes({super.key});

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
          children: [
            const Text('Atributos RPG', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Expanded(
              child: RadarChart(
                RadarChartData(
                  tickCount: 3,
                  ticksTextStyle: const TextStyle(fontSize: 8, color: Colors.transparent),
                  titlePositionPercentageOffset: 0.15,
                  radarBorderData: const BorderSide(color: Colors.white24),
                  gridBorderData: const BorderSide(color: Colors.white24, width: 1),
                  radarShape: RadarShape.polygon,
                  titleTextStyle: const TextStyle(color: Colors.white, fontSize: 10),
                  getTitle: (index, angle) {
                    switch (index) {
                      case 0: return const RadarChartTitle(text: 'DY');
                      case 1: return const RadarChartTitle(text: 'ROE');
                      case 2: return const RadarChartTitle(text: 'P/VP');
                      case 3: return const RadarChartTitle(text: 'Stock');
                      case 4: return const RadarChartTitle(text: 'P/VP');
                      case 5: return const RadarChartTitle(text: 'ROE');
                      default: return const RadarChartTitle(text: '');
                    }
                  },
                  dataSets: [
                    RadarDataSet(
                      fillColor: const Color(0xFF8A2BE2).withValues(alpha: 0.3),
                      borderColor: const Color(0xFF8A2BE2),
                      entryRadius: 0,
                      dataEntries: const [
                         RadarEntry(value: 8), RadarEntry(value: 6), RadarEntry(value: 5),
                         RadarEntry(value: 3), RadarEntry(value: 7), RadarEntry(value: 6),
                      ],
                      borderWidth: 2,
                    ),
                    RadarDataSet(
                      fillColor: AppColors.neonCyan.withValues(alpha: 0.3),
                      borderColor: AppColors.neonCyan,
                      entryRadius: 0,
                      dataEntries: const [
                         RadarEntry(value: 5), RadarEntry(value: 7), RadarEntry(value: 8),
                         RadarEntry(value: 4), RadarEntry(value: 6), RadarEntry(value: 5),
                      ],
                      borderWidth: 2,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildStatRow(Icons.healing, 'Regeneração', '2.00'),
            _buildStatRow(Icons.psychology, 'Inteligência', '1.00'),
            _buildStatRow(Icons.flash_on, 'Custo de Evocação', '1.00'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.neonCyan),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Colors.white70, fontSize: 10)),
            ],
          ),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
