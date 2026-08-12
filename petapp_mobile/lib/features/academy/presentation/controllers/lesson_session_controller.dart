import 'package:flutter/foundation.dart';
import 'package:petrimonium/core/services/total_xp_calculator.dart';
import 'package:petrimonium/features/academy/data/repositories/academy_progress_local_repository.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson_step.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_animation_state.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';
import 'package:petrimonium/features/portfolio/data/repositories/achievements_local_repository.dart';

/// Drives a single lesson play-through: current step, the learner's answer
/// (if the step is a question), and completion. Self-owned by `LessonScreen`
/// — mirrors how `MentorChatController` is created and disposed by its own
/// screen rather than shared across tabs, since a lesson session has no
/// reason to outlive the screen that plays it.
///
/// A wrong answer is never penalized: [selectOption] just records the
/// choice so [currentStepIsCorrect] can drive encouraging feedback copy —
/// there is no life/heart to lose and nothing blocks [advance].
class LessonSessionController extends ChangeNotifier {
  LessonSessionController({
    required this.lesson,
    required AcademyProgressLocalRepository academyRepository,
    required AchievementsLocalRepository achievementsRepository,
    required MascotController mascotController,
  })  : _academyRepository = academyRepository,
        _achievementsRepository = achievementsRepository,
        _mascotController = mascotController;

  final Lesson lesson;
  final AcademyProgressLocalRepository _academyRepository;
  final AchievementsLocalRepository _achievementsRepository;
  final MascotController _mascotController;

  int currentStepIndex = 0;
  int? selectedOptionIndex;
  bool hasAnswered = false;
  bool isCompleting = false;
  bool isComplete = false;

  LessonStep get currentStep => lesson.steps[currentStepIndex];
  int get totalSteps => lesson.steps.length;
  double get progress => (currentStepIndex + 1) / totalSteps;
  bool get isLastStep => currentStepIndex == totalSteps - 1;

  /// A non-question step can always advance; a question step needs an
  /// answer first — never a hard gate, just "pick one to continue."
  bool get canAdvance => currentStep is! ChoiceQuestionStep || hasAnswered;

  bool get selectedAnswerIsCorrect {
    final step = currentStep;
    if (step is ChoiceQuestionStep && selectedOptionIndex != null) {
      return selectedOptionIndex == step.correctIndex;
    }
    return true;
  }

  void selectOption(int index) {
    if (hasAnswered) return;
    selectedOptionIndex = index;
    hasAnswered = true;
    notifyListeners();
  }

  Future<void> advance() async {
    if (isCompleting || isComplete || !canAdvance) return;

    if (isLastStep) {
      await _completeLesson();
      return;
    }

    currentStepIndex++;
    selectedOptionIndex = null;
    hasAnswered = false;
    notifyListeners();
  }

  Future<void> _completeLesson() async {
    isCompleting = true;
    notifyListeners();

    await _academyRepository.markLessonCompleted(lesson.id);

    // Same composition `PortfolioController` uses, so XP always agrees
    // regardless of which feature last updated the pet — see
    // `TotalXpCalculator`'s doc comment.
    final totalXp = await TotalXpCalculator.compute(
      achievementsRepository: _achievementsRepository,
      academyRepository: _academyRepository,
    );
    await _mascotController.evaluateEvolution(_mascotController.profile.netWorth, totalXp);
    _mascotController.triggerEventAnimation(PetAnimationState.victory, duration: const Duration(seconds: 4));

    isCompleting = false;
    isComplete = true;
    notifyListeners();
  }
}
