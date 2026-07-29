import 'package:flutter/material.dart';
import 'package:petapp_mobile/core/constants/app_colors.dart';

/// Notification Presenter subsystem, template form: a small transient
/// speech bubble shown above the mascot whenever `CharacterEngine.
/// currentLine` is set. Fades/scales in and out on its own — no new art
/// required. Phase 1+ pairs this with `SpeechController`/TTS instead of
/// (or alongside) the silent text bubble.
class CharacterSpeechBubble extends StatelessWidget {
  const CharacterSpeechBubble({super.key, required this.line});

  final String? line;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: animation, child: child),
      ),
      child: line == null
          ? const SizedBox.shrink(key: ValueKey('character-speech-bubble-empty'))
          : Container(
              key: ValueKey(line),
              constraints: const BoxConstraints(maxWidth: 220),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.spaceDark.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.4)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonCyan.withValues(alpha: 0.2),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Text(
                line!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
    );
  }
}
