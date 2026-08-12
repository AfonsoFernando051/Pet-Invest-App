import 'package:petrimonium/features/academy/domain/entities/lesson_step.dart';

/// A single, short (2-5 minute) unit of the Academy curriculum: a fixed
/// sequence of [steps] worth [xpReward] once completed.
class Lesson {
  final String id;
  final String moduleId;
  final String title;
  final int order;
  final int xpReward;
  final List<LessonStep> steps;

  const Lesson({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.order,
    required this.xpReward,
    required this.steps,
  });
}
