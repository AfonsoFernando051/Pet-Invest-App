import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';

class RpgAttributes extends StatelessWidget {
  const RpgAttributes({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      backgroundColor: AppColors.spaceDark.withValues(alpha: 0.72),
      borderColor: AppColors.neonCyan.withValues(alpha: 0.3),
      borderRadius: 16,
      borderWidth: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Atributos RPG',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: RadarChart(
                RadarChartData(
                  tickCount: 3,
                  ticksTextStyle: const TextStyle(fontSize: 8, color: Colors.transparent),
                  titlePositionPercentageOffset: 0.2,
                  radarBorderData: const BorderSide(color: Colors.white24),
                  gridBorderData: const BorderSide(color: Colors.white24, width: 1),
                  radarShape: RadarShape.polygon,
                  titleTextStyle: const TextStyle(color: Colors.white, fontSize: 11),
                  getTitle: (index, angle) {
                    switch (index) {
                      case 0: return const RadarChartTitle(text: 'DY');
                      case 1: return const RadarChartTitle(text: 'ROE');
                      case 2: return const RadarChartTitle(text: 'P/L');
                      case 3: return const RadarChartTitle(text: 'P/VP');
                      case 4: return const RadarChartTitle(text: 'Cresc.');
                      case 5: return const RadarChartTitle(text: 'Div%');
                      default: return const RadarChartTitle(text: '');
                    }
                  },
                  dataSets: [
                    RadarDataSet(
                      fillColor: AppColors.neonViolet.withValues(alpha: 0.3),
                      borderColor: AppColors.neonViolet,
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
            const SizedBox(height: 10),
            _buildStatRow(Icons.healing,    'Regeneração',       '2.00'),
            _buildStatRow(Icons.psychology, 'Inteligência',      '1.00'),
            _buildStatRow(Icons.flash_on,   'Evocação',          '1.00'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.neonCyan),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(color: AppColors.subtleText, fontSize: 12),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
