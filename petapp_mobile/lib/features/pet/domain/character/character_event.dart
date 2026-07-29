/// App-level events the Character Engine's Event Reaction Engine reacts to.
///
/// Only [achievementUnlocked], [stageEvolved] and [userReturned] are
/// currently published (see `CharacterEngine`) — each is derivable from data
/// the app already has (`AchievementCatalog`, `MascotController.
/// evaluateEvolution`, `PetProfile.lastActiveAt`). The remaining values are
/// declared now so the Emotion/Personality/Speech layers can be written
/// against a stable event vocabulary, but are intentionally not published
/// yet: there is no historical net-worth series or dividend data source
/// client-side today, and fabricating one would violate the "never simulate
/// real financial information" rule (see docs/MARKET_EVENTS_ENGINE.md).
/// Wire them up once that data exists — do not fake the trigger.
enum CharacterEventType {
  achievementUnlocked,
  stageEvolved,
  userReturned,
  portfolioAllTimeHigh,
  portfolioSignificantDrop,
  dividendReceived,
  goalAchieved,
}

/// A single published occurrence of a [CharacterEventType], with any extra
/// context (e.g. `daysAway` for [CharacterEventType.userReturned]) the
/// Personality/Speech layer may want when composing a reaction.
class CharacterEvent {
  const CharacterEvent(this.type, {this.payload = const {}});

  final CharacterEventType type;
  final Map<String, Object?> payload;
}
