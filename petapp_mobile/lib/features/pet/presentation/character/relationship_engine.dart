/// Whether the player's return to the app is meaningful enough for the
/// mascot to acknowledge it, and how long they were away.
enum RelationshipMomentType { none, welcomeBack }

class RelationshipMoment {
  const RelationshipMoment.none()
      : type = RelationshipMomentType.none,
        daysAway = 0;

  const RelationshipMoment.welcomeBack(this.daysAway) : type = RelationshipMomentType.welcomeBack;

  final RelationshipMomentType type;
  final int daysAway;
}

/// Relationship Engine subsystem: a pure read of "how long was the player
/// gone" against `PetProfile.lastActiveAt` — the same signal
/// `MascotController.restingStateFor` already uses to decide whether the
/// mascot should be resting. Phase 0 keeps this to a single "missed you"
/// moment; richer memory (favorite topics, habits, streaks) is Phase 1+,
/// once there's somewhere durable to store it (see docs/CHARACTER_ENGINE.md).
class RelationshipEngine {
  const RelationshipEngine();

  /// Below one full day away, returning isn't worth a "welcome back" line —
  /// every normal daily open would otherwise trigger one.
  static const int kMinDaysAwayForWelcomeBack = 1;

  RelationshipMoment evaluate({required DateTime lastActiveAt, required DateTime now}) {
    final daysAway = now.difference(lastActiveAt).inDays;
    if (daysAway < kMinDaysAwayForWelcomeBack) return const RelationshipMoment.none();
    return RelationshipMoment.welcomeBack(daysAway);
  }
}
