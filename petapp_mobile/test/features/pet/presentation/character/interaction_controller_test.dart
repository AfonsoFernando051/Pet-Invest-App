import 'package:flutter_test/flutter_test.dart';
import 'package:petapp_mobile/features/pet/domain/entities/pet_profile.dart';
import 'package:petapp_mobile/features/pet/domain/enums/accessory_type.dart';
import 'package:petapp_mobile/features/pet/domain/enums/character_emotion.dart';
import 'package:petapp_mobile/features/pet/domain/enums/pet_accessory_id.dart';
import 'package:petapp_mobile/features/pet/domain/enums/pet_animation_state.dart';
import 'package:petapp_mobile/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petapp_mobile/features/pet/domain/repositories/mascot_repository.dart';
import 'package:petapp_mobile/features/pet/presentation/character/character_emotion_controller.dart';
import 'package:petapp_mobile/features/pet/presentation/character/interaction_controller.dart';
import 'package:petapp_mobile/features/pet/presentation/mascot/controllers/mascot_controller.dart';

class _FakeMascotRepository implements MascotRepository {
  @override
  Future<PetProfile> loadProfile() async => PetProfile();

  @override
  Future<void> saveName(String name) async {}

  @override
  Future<void> saveStage(PetEvolutionStage stage) async {}

  @override
  Future<void> saveXp(int xp) async {}

  @override
  Future<void> saveNetWorth(double netWorth) async {}

  @override
  Future<void> saveEquippedAccessories(Map<AccessoryType, PetAccessoryId> equipped) async {}

  @override
  Future<void> saveUnlockedAccessories(Set<PetAccessoryId> unlocked) async {}

  @override
  Future<void> saveLastActiveAt(DateTime lastActiveAt) async {}
}

void main() {
  late MascotController mascot;
  late CharacterEmotionController emotion;
  late InteractionController interaction;

  setUp(() {
    mascot = MascotController(repository: _FakeMascotRepository());
    emotion = CharacterEmotionController();
    interaction = InteractionController(mascot: mascot, emotion: emotion);
  });

  tearDown(() => mascot.dispose());

  test('onTap plays the happy animation and sets the happy emotion', () {
    interaction.onTap();

    expect(mascot.animationState, PetAnimationState.happy);
    expect(emotion.emotion, CharacterEmotion.happy);
  });

  test('onDoubleTap jumps and sets the veryHappy emotion', () {
    interaction.onDoubleTap();

    expect(mascot.animationState, PetAnimationState.jump);
    expect(emotion.emotion, CharacterEmotion.veryHappy);
  });

  test('onLongPress sets curious without changing the animation state', () {
    interaction.onLongPress();

    expect(mascot.animationState, PetAnimationState.idle);
    expect(emotion.emotion, CharacterEmotion.curious);
  });

  test('onDragReleased waves and sets the happy emotion', () {
    interaction.onDragReleased();

    expect(mascot.animationState, PetAnimationState.wave);
    expect(emotion.emotion, CharacterEmotion.happy);
  });
}
