import 'package:flutter/material.dart';

/// One 0-100 facet of portfolio health (shown as a radar axis + progress bar).
class HealthMetric {
  final String name;
  final double score;
  final IconData icon;

  const HealthMetric({required this.name, required this.score, required this.icon});
}

/// The full "Portfolio Health" verdict: an overall 0-100 score/letter grade
/// plus the individual facets that compose it. Computed purely client-side
/// by `PortfolioHealthCalculator` from real holdings/allocation data — there
/// is no such scoring model in the backend or product docs, so this is a
/// deliberately transparent, explainable heuristic rather than a black-box
/// "AI score".
class PortfolioHealth {
  final double overallScore;
  final List<HealthMetric> metrics;

  const PortfolioHealth({required this.overallScore, required this.metrics});

  static const empty = PortfolioHealth(overallScore: 0, metrics: []);

  String get grade {
    if (overallScore >= 90) return 'S';
    if (overallScore >= 75) return 'A';
    if (overallScore >= 60) return 'B';
    if (overallScore >= 40) return 'C';
    return 'D';
  }
}
