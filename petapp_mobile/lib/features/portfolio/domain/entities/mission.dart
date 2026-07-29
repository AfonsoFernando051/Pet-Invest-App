import 'package:flutter/material.dart';

/// A resolved, ready-to-render mission — progress is computed by
/// `MissionCatalog.evaluate` against a real [PortfolioStats] snapshot, not
/// stored/mutated on this object.
class Mission {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final double current;
  final double target;
  final int xpReward;

  const Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.current,
    required this.target,
    required this.xpReward,
  });

  bool get isComplete => current >= target;

  double get progress => target <= 0 ? (isComplete ? 1.0 : 0.0) : (current / target).clamp(0.0, 1.0);
}
