/// App-level events the Character Engine's Event Reaction Engine reacts to.
///
/// [achievementUnlocked], [stageEvolved], [userReturned] and
/// [missionCompleted] are currently published (see `CharacterEngine`,
/// `PortfolioController._evaluateGamification`) — each is derivable from
/// data the app already has (`AchievementCatalog`, `MissionCatalog`,
/// `MascotController.evaluateEvolution`, `PetProfile.lastActiveAt`). The
/// remaining values are declared now so the Emotion/Personality/Speech
/// layers can be written against a stable event vocabulary, but are
/// intentionally not published yet: there is no historical net-worth series
/// or dividend data source client-side today, and fabricating one would
/// violate the "never simulate real financial information" rule (see
/// docs/MARKET_EVENTS_ENGINE.md). Wire them up once that data exists — do
/// not fake the trigger.
///
/// This app doesn't model two events from the brief that inspired this
/// vocabulary: "UserLevelUp" is [stageEvolved] under a different name (there
/// is no separate numeric level — evolution tier *is* the level system);
/// "PortfolioImported" isn't modeled at all — this app has no CSV/broker
/// import feature to derive it from, so there is nothing real to publish.
/// "MarketCrash" is [portfolioSignificantDrop].
enum CharacterEventType {
  achievementUnlocked,
  stageEvolved,
  userReturned,
  missionCompleted,
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
