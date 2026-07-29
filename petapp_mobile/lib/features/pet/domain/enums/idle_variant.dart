/// A flavor of "doing nothing" — cycled by the Behavior Controller
/// (`IdleBehaviorController`) only while the mascot's [PetAnimationState] is
/// `idle`, so the pet never sits in one static loop.
///
/// Matches the "GAMEPLAY POSES"/"POSES" grids drawn for every species in
/// the reference concept sheets (`assets/pets/{dog,cat,wolf,fox,bear,
/// lion}.png`), restricted to the poses that make sense as unprompted idle
/// behavior (locomotion — walk/run/jump — and event reactions — celebrate/
/// victory/laugh — are `PetAnimationState`, not idle flavor). [breathing]
/// and [blinking] correspond to those sheets' own "IDLE (8)" and "BLINK (6)"
/// sprite sheets — the baseline idle loop itself, before layering in the
/// less frequent stretch/sit/watch variety.
enum IdleVariant {
  breathing,
  blinking,
  stretch,
  sit,
  layDown,
  lookUp,
  lookDown,
  think,
  wave,
  eat,
  drink,
  dance,
}
