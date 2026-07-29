import 'package:flutter_test/flutter_test.dart';
import 'package:petapp_mobile/features/pet/domain/enums/pet_animation_state.dart';
import 'package:petapp_mobile/features/pet/presentation/character/idle_behavior_controller.dart';

void main() {
  group('IdleBehaviorController', () {
    test('cycles to a new variant while idle', () async {
      final controller = IdleBehaviorController(
        minInterval: Duration.zero,
        maxInterval: Duration.zero,
      );
      addTearDown(controller.dispose);

      final initial = controller.variant;
      controller.start();
      await Future.delayed(Duration.zero);

      expect(controller.variant, isNot(initial));
    });

    test('freezes as soon as a non-idle animation state takes over', () async {
      final controller = IdleBehaviorController(
        minInterval: Duration.zero,
        maxInterval: Duration.zero,
      );
      addTearDown(controller.dispose);

      controller.start();
      await Future.delayed(Duration.zero);
      controller.onAnimationStateChanged(PetAnimationState.celebrate);
      final frozen = controller.variant;

      await Future.delayed(Duration.zero);
      await Future.delayed(Duration.zero);

      expect(controller.variant, frozen);
    });

    test('resumes cycling once the mascot returns to idle', () async {
      final controller = IdleBehaviorController(
        minInterval: Duration.zero,
        maxInterval: Duration.zero,
      );
      addTearDown(controller.dispose);

      controller.start();
      controller.onAnimationStateChanged(PetAnimationState.celebrate);
      final frozen = controller.variant;

      controller.onAnimationStateChanged(PetAnimationState.idle);
      await Future.delayed(Duration.zero);

      expect(controller.variant, isNot(frozen));
    });
  });
}
