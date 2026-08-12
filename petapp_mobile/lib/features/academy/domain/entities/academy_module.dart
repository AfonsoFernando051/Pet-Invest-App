import 'package:flutter/material.dart';

/// A themed group of lessons (e.g. "Investor Foundations", "Fixed Income").
/// [contentAvailable] distinguishes real, playable modules from curriculum
/// placeholders shown as "coming soon" — the progression system's full shape
/// is visible from day one without shipping unwritten content.
class AcademyModule {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int order;
  final List<String> lessonIds;
  final bool contentAvailable;

  const AcademyModule({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.order,
    this.lessonIds = const [],
    this.contentAvailable = false,
  });
}
