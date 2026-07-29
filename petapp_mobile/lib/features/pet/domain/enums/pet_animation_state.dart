/// Reactive animation states the mascot can be rendered in — the top-level
/// state machine driven by app events (see
/// `MascotController.triggerEventAnimation`), as distinct from idle micro-
/// motion ([IdleVariant]) or facial/emotional tint ([CharacterEmotion]).
///
/// [idle], [celebrate], [think], [sleep] and [victory] are the states
/// currently wired up to real app events; [happy] is the short-lived tap/
/// pet reaction. The remaining values (walk/run/jump/sit/layDown/eat/drink/
/// dance/wave/stretch/lookUp/lookDown/laugh) aren't triggered by any code
/// path yet, but are declared now because every one of them is a named,
/// already-designed "GAMEPLAY POSES"/"POSES" entry in the reference concept
/// sheets (`assets/pets/{dog,cat,wolf,fox,bear,lion}.png`) — so `assetKey`
/// already resolves to the exact file name a future Lottie/PNG export of
/// that pose should use, with no remapping required.
enum PetAnimationState {
  idle,
  celebrate,
  think,
  sleep,
  victory,
  happy,
  walk,
  run,
  jump,
  sit,
  layDown,
  eat,
  drink,
  dance,
  wave,
  stretch,
  lookUp,
  lookDown,
  laugh,
}

extension PetAnimationStateAsset on PetAnimationState {
  /// File name (without extension) used to look up the Lottie animation
  /// under `assets/mascot/animations/`.
  String get assetKey => name;
}
