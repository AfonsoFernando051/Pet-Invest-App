import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:petapp_mobile/core/constants/app_colors.dart';
import 'package:petapp_mobile/core/widgets/glass_card.dart';
import 'package:petapp_mobile/features/portfolio/domain/entities/portfolio_health.dart';
import 'package:petapp_mobile/features/portfolio/presentation/widgets/shared/section_label.dart';

/// The RPG-inspired "Portfolio Health" panel: an overall 0-100 score/grade,
/// a radar chart across six facets, and per-facet animated progress bars.
class PortfolioHealthCard extends StatelessWidget {
  const PortfolioHealthCard({super.key, required this.health});

  final PortfolioHealth health;

  Color get _scoreColor {
    if (health.overallScore >= 75) return AppColors.positiveGreen;
    if (health.overallScore >= 50) return AppColors.goldenBorder;
    return AppColors.negativeRed;
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      backgroundColor: AppColors.spaceDark.withValues(alpha: 0.68),
      borderColor: AppColors.neonViolet.withValues(alpha: 0.35),
      borderRadius: 20,
      borderWidth: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SectionLabel('SAÚDE DO PORTFÓLIO'),
                _ScoreBadge(score: health.overallScore, grade: health.grade, color: _scoreColor),
              ],
            ),
            const SizedBox(height: 12),
            if (health.metrics.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'Invista em ao menos um ativo para revelar sua saúde de portfólio.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.subtleText, fontSize: 12),
                  ),
                ),
              )
            else ...[
              SizedBox(
                height: 190,
                child: RadarChart(
                  RadarChartData(
                    tickCount: 4,
                    ticksTextStyle: const TextStyle(fontSize: 0, color: Colors.transparent),
                    titlePositionPercentageOffset: 0.18,
                    radarBorderData: const BorderSide(color: Colors.white24),
                    gridBorderData: const BorderSide(color: Colors.white24, width: 1),
                    radarShape: RadarShape.polygon,
                    titleTextStyle: const TextStyle(color: Colors.white, fontSize: 10),
                    getTitle: (index, angle) => RadarChartTitle(
                      text: index < health.metrics.length ? _shortName(health.metrics[index].name) : '',
                    ),
                    dataSets: [
                      RadarDataSet(
                        fillColor: AppColors.neonCyan.withValues(alpha: 0.25),
                        borderColor: AppColors.neonCyan,
                        entryRadius: 2,
                        borderWidth: 2,
                        dataEntries: [for (final m in health.metrics) RadarEntry(value: m.score)],
                      ),
                    ],
                  ),
                  duration: const Duration(milliseconds: 600),
                ),
              ),
              const SizedBox(height: 8),
              for (final metric in health.metrics) _MetricBar(metric: metric),
            ],
          ],
        ),
      ),
    );
  }

  String _shortName(String name) => name.length > 10 ? '${name.substring(0, 9)}…' : name;
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score, required this.grade, required this.color});

  final double score;
  final String grade;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.6)),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 10, spreadRadius: 1)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(grade, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(width: 4),
          Text(
            score.toStringAsFixed(0),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _MetricBar extends StatelessWidget {
  const _MetricBar({required this.metric});

  final HealthMetric metric;

  Color get _color {
    if (metric.score >= 75) return AppColors.positiveGreen;
    if (metric.score >= 45) return AppColors.goldenBorder;
    return AppColors.negativeRed;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(metric.icon, size: 14, color: AppColors.neonCyan),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Text(metric.name, style: const TextStyle(color: AppColors.subtleText, fontSize: 11)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Stack(
                children: [
                  Container(height: 6, color: Colors.white.withValues(alpha: 0.08)),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: metric.score / 100),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => FractionallySizedBox(
                      widthFactor: value.clamp(0.0, 1.0),
                      child: Container(height: 6, color: _color),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 28,
            child: Text(
              metric.score.toStringAsFixed(0),
              textAlign: TextAlign.end,
              style: TextStyle(color: _color, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
