import 'package:flutter/foundation.dart';
import 'package:petrimonium/features/academy/data/repositories/academy_progress_local_repository.dart';
import 'package:petrimonium/features/academy/domain/entities/academy_module.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson.dart';
import 'package:petrimonium/features/academy/domain/services/academy_catalog.dart';
import 'package:petrimonium/features/academy/domain/services/academy_progress_calculator.dart';

/// Owns the Academy module list / overview state: loads persisted progress
/// and exposes derived status per module/lesson. Mirrors `PortfolioController`
/// in shape (a `ChangeNotifier` wrapping a repository + pure domain services).
class AcademyController extends ChangeNotifier {
  AcademyController({required AcademyProgressLocalRepository repository}) : _repository = repository;

  final AcademyProgressLocalRepository _repository;

  bool isLoading = true;
  Set<String> completedLessonIds = {};

  List<AcademyModule> get modules => AcademyCatalog.modules;

  Lesson? get nextLesson => AcademyProgressCalculator.nextLessonToContinue(completedIds: completedLessonIds);

  int get totalXpEarned => AcademyCatalog.xpEarnedFor(completedLessonIds);

  Future<void> load() async {
    isLoading = true;
    notifyListeners();

    completedLessonIds = await _repository.loadCompletedLessonIds();

    isLoading = false;
    notifyListeners();
  }

  ModuleStatus statusFor(AcademyModule module) {
    return AcademyProgressCalculator.moduleStatus(module: module, completedIds: completedLessonIds);
  }

  int completedLessonCountFor(AcademyModule module) {
    return module.lessonIds.where(completedLessonIds.contains).length;
  }
}
