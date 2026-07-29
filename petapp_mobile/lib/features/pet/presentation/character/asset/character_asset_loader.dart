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
  /// a species-specific Lottie export, then the shared placeholder path
  /// `MascotController`/`CharacterWidget` already used pre-species-art.
  /// Neither exists on disk yet (`assets/characters/*/poses/` are seeded
  /// with only `.gitkeep`) — `CharacterWidget`'s `errorBuilder` chain falls
  /// through to the evolution-stage PNG after these, unaffected.
  List<String> posePaths(PetSpecieEnum species, PetAnimationState state) => [
        'assets/characters/${_speciesKey(species)}/poses/${state.assetKey}.json',
        'assets/mascot/animations/${state.assetKey}.json',
      ];

  /// The species-specific face for [emotion]. No shared fallback exists for
  /// expressions (unlike poses) — if this is missing, `CharacterWidget`
  /// simply renders no expression overlay, continuing to convey emotion via
  /// `EmotionVisualProfile`'s aura/breathe retinting alone.
  List<String> expressionPaths(PetSpecieEnum species, CharacterEmotion emotion) => [
        'assets/characters/${_speciesKey(species)}/expressions/${emotion.name}.png',
      ];

  static String _speciesKey(PetSpecieEnum species) => species.name.toLowerCase();
}
