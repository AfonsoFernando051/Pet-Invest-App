import 'package:petrimonium/features/academy/domain/entities/academy_module.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson.dart';
import 'package:petrimonium/features/academy/domain/services/academy_catalog.dart';

enum LessonStatus { locked, available, completed }

enum ModuleStatus { comingSoon, available, inProgress, completed }

/// Pure functions deriving lesson/module progression state from
/// [AcademyCatalog] (static) crossed with the set of completed lesson ids
/// (persisted). Mirrors `MissionCatalog.evaluate()`: nothing here is stored
/// as a separate value that could drift from the source of truth.
class AcademyProgressCalculator {
  const AcademyProgressCalculator._();

  /// A lesson unlocks once the previous lesson in its module is completed;
  /// the first lesson of a module is always available.
  static LessonStatus lessonStatus({
    required Lesson lesson,
    required Set<String> completedIds,
  }) {
    if (completedIds.contains(lesson.id)) return LessonStatus.completed;

    final moduleLessons = AcademyCatalog.lessonsForModule(lesson.moduleId);
    final index = moduleLessons.indexWhere((l) => l.id == lesson.id);
    if (index <= 0) return LessonStatus.available;

    final previous = moduleLessons[index - 1];
    return completedIds.contains(previous.id) ? LessonStatus.available : LessonStatus.locked;
  }

  static ModuleStatus moduleStatus({
    required AcademyModule module,
    required Set<String> completedIds,
  }) {
    if (!module.contentAvailable || module.lessonIds.isEmpty) return ModuleStatus.comingSoon;

    final completedInModule = module.lessonIds.where(completedIds.contains).length;
    if (completedInModule == 0) return ModuleStatus.available;
    if (completedInModule == module.lessonIds.length) return ModuleStatus.completed;
    return ModuleStatus.inProgress;
  }

  /// The next lesson the learner should continue with: the first
  /// not-yet-completed lesson of the first module with real content,
  /// scanning modules in curriculum order. `null` once every available
  /// lesson is completed.
  static Lesson? nextLessonToContinue({required Set<String> completedIds}) {
    final orderedModules = [...AcademyCatalog.modules]..sort((a, b) => a.order.compareTo(b.order));
    for (final module in orderedModules) {
      if (!module.contentAvailable) continue;
      for (final lesson in AcademyCatalog.lessonsForModule(module.id)) {
        if (!completedIds.contains(lesson.id)) return lesson;
      }
    }
    return null;
  }
}
