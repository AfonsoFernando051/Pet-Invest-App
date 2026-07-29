import 'package:petapp_mobile/features/pet/domain/enums/character_emotion.dart';
import 'package:petapp_mobile/features/pet/domain/enums/pet_animation_state.dart';
import 'package:petapp_mobile/features/pet/presentation/character/character_emotion_controller.dart';
import 'package:petapp_mobile/features/pet/presentation/mascot/controllers/mascot_controller.dart';

/// Interaction Controller subsystem: translates raw gestures into
/// animation-state/emotion changes on the two controllers it holds. Neither
/// controller here is owned by this class — both are shared with the rest
/// of `CharacterEngine`, so a reaction triggered by touch is indistinguishable
/// from one triggered by an app event. Not a `ChangeNotifier` itself: it has
/// no state of its own, only behavior, and both controllers it calls into
/// already notify their own listeners.
///
/// `CharacterWidget` calls these methods from its `GestureDetector` — it
/// never calls `triggerEventAnimation`/`setEmotion` directly, so no screen
/// manipulates the mascot's animation outside the Character Engine.
class InteractionController {
  InteractionController({
    required MascotController mascot,
    required CharacterEmotionController emotion,
  })  : _mascot = mascot,
        _emotion = emotion;

  final MascotController _mascot;
  final CharacterEmotionController _emotion;

  /// A single tap/pet — the mascot's lightest, most frequent reaction.
  void onTap() {
    _mascot.triggerEventAnimation(
      PetAnimationState.happy,
      duration: const Duration(milliseconds: 900),
    );
    _emotion.setEmotion(CharacterEmotion.happy);
  }

  /// A double tap — a bigger, more excited reaction than a single tap.
  void onDoubleTap() {
    _mascot.triggerEventAnimation(
      PetAnimationState.jump,
      duration: const Duration(milliseconds: 1200),
    );
    _emotion.setEmotion(CharacterEmotion.veryHappy);
  }

  /// A long press — the mascot leans in, curious, without switching pose.
  void onLongPress() {
    _emotion.setEmotion(CharacterEmotion.curious);
  }

  /// Released after being dragged around the screen — a friendly wave.
  void onDragReleased() {
    _mascot.triggerEventAnimation(
      PetAnimationState.wave,
      duration: const Duration(milliseconds: 1200),
    );
    _emotion.setEmotion(CharacterEmotion.happy);
  }
}
