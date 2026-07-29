/// Lip Sync Controller subsystem — Phase 2+ extension point, not wired into
/// the UI yet. Depends on `SpeechController` actually producing audio first.
/// Implementations should map elapsed playback time to one of these mouth
/// shapes; perfect sync isn't required, just natural-looking movement (see
/// docs/CHARACTER_ENGINE.md).
enum MouthShape { closed, halfOpen, open, smile, wideOpen, surprised }

abstract class LipSyncController {
  Stream<MouthShape> get mouthShape;

  void syncTo(String line, Duration audioDuration);

  void stop();
}
