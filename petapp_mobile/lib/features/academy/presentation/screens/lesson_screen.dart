import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/background_presets.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/cosmic_background.dart';
import 'package:petrimonium/core/widgets/game_button.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson_step.dart';
import 'package:petrimonium/features/academy/presentation/controllers/lesson_session_controller.dart';
import 'package:petrimonium/features/academy/presentation/widgets/academy_progress_bar.dart';
import 'package:petrimonium/features/academy/presentation/widgets/lesson_complete_card.dart';
import 'package:petrimonium/features/academy/presentation/widgets/steps/choice_question_step_view.dart';
import 'package:petrimonium/features/academy/presentation/widgets/steps/example_step_view.dart';
import 'package:petrimonium/features/academy/presentation/widgets/steps/explanation_step_view.dart';
import 'package:petrimonium/features/academy/presentation/widgets/steps/summary_step_view.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';

/// The step player: one [LessonStep] at a time, a top progress bar, and a
/// single "Continuar" action that only enables once a question step has an
/// answer. Ends in [LessonCompleteCard] — a lesson always completes, there
/// is no fail/restart state (see `docs/ACADEMY_ENGINE.md`, no lives/hearts).
class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key, required this.lesson, required this.mascotController});

  final Lesson lesson;
  final MascotController mascotController;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late final LessonSessionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LessonSessionController(
      lesson: widget.lesson,
      academyRepository: DI.academyProgressRepository,
      achievementsRepository: DI.achievementsRepository,
      mascotController: widget.mascotController,
    );
    _controller.addListener(_onChanged);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  // Academia is a bottom-nav tab living on the Dashboard's root route (its
  // `IndexedStack` keeps the tab's own state, `_selectedIndex`, alive) —
  // "back to Academia" is just "pop every pushed screen back to that root".
  void _backToAcademy() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: tokens.textPrimary),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: _controller.isComplete
            ? null
            : Padding(
                padding: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
                child: AcademyProgressBar(progress: _controller.progress),
              ),
      ),
      body: CosmicBackground(
        // Lesson steps include quiz/exercise questions — the app's most
        // cognitively demanding screen, so it gets the quietest preset.
        intensity: BackgroundIntensity.focus,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: SingleChildScrollView(
                // Rebuilds this screen's chrome (button labels) if the user
                // switches language in Settings mid-lesson.
                child: ValueListenableBuilder<String>(
                  valueListenable: Translator.languageNotifier,
                  builder: (context, _, __) =>
                      _controller.isComplete ? _buildComplete(context) : _buildStep(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context) {
    final step = _controller.currentStep;
    final Widget stepView = switch (step) {
      ExplanationStep() => ExplanationStepView(step: step),
      ExampleStep() => ExampleStepView(step: step),
      ChoiceQuestionStep() => ChoiceQuestionStepView(
          step: step,
          selectedIndex: _controller.selectedOptionIndex,
          hasAnswered: _controller.hasAnswered,
          onSelect: _controller.selectOption,
        ),
      SummaryStep() => SummaryStepView(step: step),
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        stepView,
        const SizedBox(height: 32),
        GameButton(
          label: Translator.translate(
            _controller.isLastStep ? AppStrings.academyConcludeButton : AppStrings.academyContinueButton,
          ),
          isLoading: _controller.isCompleting,
          onPressed: _controller.canAdvance ? _controller.advance : null,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildComplete(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: LessonCompleteCard(
        lessonTitle: widget.lesson.title,
        xpEarned: widget.lesson.xpReward,
        onContinue: () {
          if (Navigator.canPop(context)) Navigator.pop(context);
        },
        onBackToAcademy: _backToAcademy,
      ),
    );
  }
}
