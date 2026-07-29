/// A flavor of "doing nothing" — cycled by the Behavior Controller
/// (`IdleBehaviorController`) only while the mascot's [PetAnimationState] is
/// `idle`, so the pet never sits in one static idle loop. Each variant is
/// implementable today with plain `Transform`/tween adjustments on the
/// existing Lottie/PNG mascot layer — none require new per-variant art.
enum IdleVariant {
  breathing,
  lookAround,
  stretch,
  tailWag,
  sit,
  watchCoins,
  watchNotification,
}
