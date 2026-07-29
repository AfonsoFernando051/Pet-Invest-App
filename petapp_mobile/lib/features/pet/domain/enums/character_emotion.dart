/// The mascot's current emotional state — orthogonal to
/// [PetAnimationState] (which animation clip/fallback art is playing) and to
/// [IdleVariant] (which idle micro-motion is playing). The Emotion
/// Controller subsystem derives this from app events and uses it to tint/
/// pace the *existing* visual layers (see `CharacterEmotionController`),
/// independent of which clip or idle flavor is currently rendering.
enum CharacterEmotion {
  happy,
  excited,
  curious,
  calm,
  focused,
  thinking,
  confused,
  surprised,
  proud,
  sad,
  concerned,
  sleeping,
  celebrating,
  motivated,
}
