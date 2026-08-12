import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson_step.dart';

/// Renders any [ChoiceQuestionStep] (multiple choice, true/false-as-2-options,
/// or an applied scenario) with one shared widget. A wrong answer is never a
/// penalty — [_FeedbackCard] always reads as supportive, and nothing here
/// blocks the learner from continuing (see `LessonSessionController.canAdvance`).
class ChoiceQuestionStepView extends StatelessWidget {
  const ChoiceQuestionStepView({
    super.key,
    required this.step,
    required this.selectedIndex,
    required this.hasAnswered,
    required this.onSelect,
  });

  final ChoiceQuestionStep step;
  final int? selectedIndex;
  final bool hasAnswered;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final isApply = step.framing == ChoiceStepFraming.apply;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(isApply ? Icons.psychology_outlined : Icons.quiz_outlined, color: AppColors.neonCyan, size: 18),
            const SizedBox(width: 8),
            Text(
              Translator.translate(isApply ? AppStrings.academyApplyLabel : AppStrings.academyMicroExerciseLabel),
              style: const TextStyle(color: AppColors.neonCyan, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          step.prompt,
          style: TextStyle(color: tokens.textPrimary, fontSize: 17, fontWeight: FontWeight.bold, height: 1.4),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < step.options.length; i++) ...[
          _OptionTile(
            label: step.options[i],
            state: _stateFor(i),
            onTap: hasAnswered ? null : () => onSelect(i),
          ),
          const SizedBox(height: 8),
        ],
        if (hasAnswered) ...[
          const SizedBox(height: 8),
          _FeedbackCard(isCorrect: selectedIndex == step.correctIndex, explanation: step.explanation),
        ],
      ],
    );
  }

  _OptionState _stateFor(int index) {
    if (!hasAnswered) return _OptionState.neutral;
    if (index == step.correctIndex) return _OptionState.correct;
    if (index == selectedIndex) return _OptionState.incorrect;
    return _OptionState.dimmed;
  }
}

enum _OptionState { neutral, correct, incorrect, dimmed }

class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.label, required this.state, required this.onTap});

  final String label;
  final _OptionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final (Color borderColor, Color bgColor, IconData? trailingIcon) = switch (state) {
      _OptionState.neutral => (
          tokens.border,
          tokens.surface.withValues(alpha: context.isDarkMode ? 0.4 : 0.94),
          null,
        ),
      _OptionState.correct => (tokens.success, tokens.success.withValues(alpha: 0.14), Icons.check_circle),
      _OptionState.incorrect => (
          AppColors.neonPink,
          AppColors.neonPink.withValues(alpha: 0.12),
          Icons.cancel_outlined,
        ),
      _OptionState.dimmed => (tokens.border, tokens.surface.withValues(alpha: 0.2), null),
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: state == _OptionState.dimmed ? tokens.textTertiary : tokens.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
              if (trailingIcon != null) Icon(trailingIcon, color: borderColor, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.isCorrect, required this.explanation});

  final bool isCorrect;
  final String explanation;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    // Supportive tone either way — there's no "wrong" framing, only a next
    // beat of understanding. See ACADEMY_ENGINE.md's no-punishment rule.
    final accent = isCorrect ? tokens.success : AppColors.neonCyan;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(isCorrect ? Icons.emoji_events_outlined : Icons.auto_awesome, color: accent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Translator.translate(
                    isCorrect ? AppStrings.academyCorrectFeedbackTitle : AppStrings.academyIncorrectFeedbackTitle,
                  ),
                  style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(explanation, style: TextStyle(color: tokens.textSecondary, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
