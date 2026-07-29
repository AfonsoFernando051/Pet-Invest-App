import 'package:petapp_mobile/features/pet/data/models/pet_specie_enum.dart';
import 'package:petapp_mobile/features/pet/domain/enums/character_emotion.dart';
import 'package:petapp_mobile/features/pet/domain/enums/pet_animation_state.dart';

/// Resolves species-aware asset paths for the Character Engine. Pure and
/// stateless — no I/O, no caching — because Flutter's asset bundle already
/// caches decoded images/Lottie compositions, and "does this file exist" is
/// already handled by `errorBuilder` fallback chains in `CharacterWidget`,
/// the same graceful-degradation pattern `_EvolutionFallback` already used
/// before this class existed. This is the single place that knows the
/// `assets/characters/<species>/...` convention, so nothing else needs to
/// hardcode it.
class CharacterAssetLoader {
  const CharacterAssetLoader();

  /// Ordered candidates for [state]'s animation clip, most specific first:
  /// a species-specific Lottie export (not authored yet), then a species-
  /// specific static pose PNG (real, sliced from `assets/pets/*.png` for
  /// cat/wolf/fox/bear/lion — see docs/CHARACTER_ENGINE.md), then the
  /// shared placeholder Lottie path `MascotController`/`CharacterWidget`
  /// already used pre-species-art. `CharacterWidget`'s chain falls through
  /// to the evolution-stage PNG after these if none resolve (e.g. every
  /// state for DOG, and states with no sliced pose for the other species).
  List<String> posePaths(PetSpecieEnum species, PetAnimationState state) => [
        'assets/characters/${_speciesKey(species)}/poses/${state.assetKey}.json',
        'assets/characters/${_speciesKey(species)}/poses/${state.assetKey}.png',
        'assets/mascot/animations/${state.assetKey}.json',
      ];

  /// The species-specific face for [emotion]. No shared fallback exists for
  /// expressions (unlike poses) — if this is missing (every emotion for
  /// DOG — see docs/CHARACTER_ENGINE.md), `CharacterWidget` simply renders
  /// no expression badge, continuing to convey emotion via
  /// `EmotionVisualProfile`'s aura/breathe retinting alone.
  List<String> expressionPaths(PetSpecieEnum species, CharacterEmotion emotion) => [
        'assets/characters/${_speciesKey(species)}/expressions/${emotion.name}.png',
      ];

  static String _speciesKey(PetSpecieEnum species) => species.name.toLowerCase();
}
