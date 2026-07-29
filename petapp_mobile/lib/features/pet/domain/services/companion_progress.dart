import 'package:petapp_mobile/features/pet/domain/enums/pet_evolution_stage.dart';

/// The 5 broad, number-free progression buckets the Companion Home screen
/// shows instead of the raw 9-tier [PetEvolutionStage] — "focus on
/// progression, not unnecessary numbers" per the redesign brief.
enum EvolutionBucket { baby, young, adult, master, legendary }

extension EvolutionBucketOf on PetEvolutionStage {
  /// Groups the 9 internal tiers into the 5 buckets the UI actually shows.
  EvolutionBucket get bucket {
    final tier = this.tier;
    if (tier <= 1) return EvolutionBucket.baby;
    if (tier <= 3) return EvolutionBucket.young;
    if (tier <= 5) return EvolutionBucket.adult;
    if (tier <= 7) return EvolutionBucket.master;
    return EvolutionBucket.legendary;
  }
}

/// A companion's level within its current evolution stage — distinct from
/// [EvolutionBucket] (the big visual milestone): leveling up is frequent and
/// granular, evolving is rare and dramatic.
class CompanionLevel {
  const CompanionLevel({
    required this.level,
    required this.xpIntoLevel,
    required this.xpForNextLevel,
  });

  final int level;
  final int xpIntoLevel;
  final int xpForNextLevel;

  double get progress =>
      xpForNextLevel == 0 ? 1.0 : xpIntoLevel / xpForNextLevel;
}

/// Friendship tiers shown alongside the raw percentage — a plain number
/// ("82%") reads like a stat; pairing it with a warm label keeps the
/// emotional framing the redesign calls for.
enum FriendshipTier { newFriends, growingCloser, greatFriends, bestFriends }

/// Pure, presentation-agnostic progression math for the Companion Home
/// screen. Every input here already exists on `PetProfile` — nothing is
/// fabricated, only derived.
class CompanionProgress {
  const CompanionProgress._();

  static const int xpPerLevel = 250;

  static CompanionLevel levelFor(int xp) {
    final clampedXp = xp < 0 ? 0 : xp;
    return CompanionLevel(
      level: (clampedXp ~/ xpPerLevel) + 1,
      xpIntoLevel: clampedXp % xpPerLevel,
      xpForNextLevel: xpPerLevel,
    );
  }

  static int daysTogether({required DateTime? companionSince, DateTime? now}) {
    if (companionSince == null) return 0;
    final today = now ?? DateTime.now();
    final diff = today.difference(companionSince).inDays;
    return diff < 0 ? 0 : diff;
  }

  /// 0–100: grows with time spent together and with accumulated XP (a proxy
  /// for how much the player has actually engaged with their companion).
  static int friendshipScore({
    required DateTime? companionSince,
    required int xp,
    DateTime? now,
  }) {
    final days = daysTogether(companionSince: companionSince, now: now);
    final raw = (days * 3) + (xp / 20);
    return raw.clamp(0, 100).round();
  }

  static FriendshipTier friendshipTierFor(int score) {
    if (score >= 85) return FriendshipTier.bestFriends;
    if (score >= 55) return FriendshipTier.greatFriends;
    if (score >= 25) return FriendshipTier.growingCloser;
    return FriendshipTier.newFriends;
  }
}
