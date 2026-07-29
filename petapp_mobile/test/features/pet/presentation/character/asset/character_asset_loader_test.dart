import 'package:flutter_test/flutter_test.dart';
import 'package:petapp_mobile/features/pet/data/models/pet_specie_enum.dart';
import 'package:petapp_mobile/features/pet/domain/enums/character_emotion.dart';
import 'package:petapp_mobile/features/pet/domain/enums/pet_animation_state.dart';
import 'package:petapp_mobile/features/pet/presentation/character/asset/character_asset_loader.dart';

void main() {
  const loader = CharacterAssetLoader();

  group('posePaths', () {
    test('prefers species Lottie, then species PNG, then the shared Lottie', () {
      final paths = loader.posePaths(PetSpecieEnum.FOX, PetAnimationState.idle);

      expect(paths, [
        'assets/characters/fox/poses/idle.json',
        'assets/characters/fox/poses/idle.png',
        'assets/mascot/animations/idle.json',
      ]);
    });

    test('uses lowercase species names, not the reference sheets\' "leon" typo', () {
      final paths = loader.posePaths(PetSpecieEnum.LION, PetAnimationState.celebrate);

      expect(paths.first, 'assets/characters/lion/poses/celebrate.json');
      expect(paths[1], 'assets/characters/lion/poses/celebrate.png');
    });
  });

  group('expressionPaths', () {
    test('resolves a single species-specific candidate with no shared fallback', () {
      final paths = loader.expressionPaths(PetSpecieEnum.BEAR, CharacterEmotion.proud);

      expect(paths, ['assets/characters/bear/expressions/proud.png']);
    });
  });
}
