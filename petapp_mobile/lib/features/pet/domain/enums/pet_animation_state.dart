/// Reactive animation states the mascot can be rendered in.
///
/// [idle], [celebrate], [think], [sleep] and [victory] are driven by app
/// events (see `MascotController.triggerEventAnimation`). [happy] is a
/// short-lived reaction to direct user interaction (tap / pet).
enum PetAnimationState {
  idle,
  celebrate,
  think,
  sleep,
  victory,
  happy,
}

extension PetAnimationStateAsset on PetAnimationState {
  /// Generic fallback animation file name (without extension).
  /// Used when no species-specific file exists.
  String get assetKey => name;

  /// Species-specific animation key, e.g. `dog_idle`.
  /// Primary lookup under `assets/mascot/animations/`.
  String speciesAssetKey(String specie) =>
      '${specie.toLowerCase()}_$name';
}
