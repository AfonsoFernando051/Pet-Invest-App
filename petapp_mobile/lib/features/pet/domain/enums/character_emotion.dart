/// The mascot's current emotional state — orthogonal to
/// [PetAnimationState] (which animation clip/fallback art is playing) and to
/// [IdleVariant] (which idle micro-motion is playing). The Emotion
/// Controller subsystem derives this from app events and uses it to tint/
/// pace the mascot's visual layers (see `CharacterEmotionController`).
///
/// These 25 values are not invented — they match, one for one, the named
/// "EXPRESSIONS" grid drawn for every species in the reference concept
/// sheets at `assets/pets/{dog,cat,wolf,fox,bear,lion}.png` (e.g.
/// `assets/pets/leon.png`: NEUTRAL, HAPPY, VERY HAPPY, LAUGHING, CURIOUS,
/// THINKING, DETERMINED, CONFIDENT, PROUD, EXCITED, SURPRISED, CONFUSED,
/// EMBARRASSED, SAD, CRYING, SLEEPY, SLEEPING, LOVE, SCARED, DIZZY, SICK,
/// SHOCKED, ANGRY, PLAYFUL; `wolf.png`/`cat.png` additionally label
/// MOTIVATED). Keeping the enum names identical to those labels means a
/// future artist can slice that reference sheet directly into per-emotion
/// assets keyed by `name` — no remapping — once Phase 1+ actually renders
/// per-emotion art instead of retinting the existing single-pose fallback.
enum CharacterEmotion {
  neutral,
  happy,
  veryHappy,
  laughing,
  curious,
  thinking,
  determined,
  confident,
  proud,
  excited,
  motivated,
  surprised,
  confused,
  embarrassed,
  sad,
  crying,
  sleepy,
  sleeping,
  love,
  scared,
  dizzy,
  sick,
  shocked,
  angry,
  playful,
}
