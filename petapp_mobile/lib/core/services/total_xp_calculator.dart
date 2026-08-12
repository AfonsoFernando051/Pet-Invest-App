import 'package:petrimonium/features/academy/data/repositories/academy_progress_local_repository.dart';
import 'package:petrimonium/features/portfolio/data/repositories/achievements_local_repository.dart';
import 'package:petrimonium/features/portfolio/domain/services/achievement_catalog.dart';

/// The single place that composes total game XP from every source that
/// grants it (achievements, Academy lessons, …), so
/// `MascotController.evaluateEvolution` — which overwrites the pet's stored
/// XP rather than adding to it — is always called with the same total
/// regardless of which feature triggered the recomputation. Without this,
/// a portfolio refresh calling `evaluateEvolution` with achievement XP alone
/// would silently erase XP earned from Academy lessons, and vice versa.
class TotalXpCalculator {
  const TotalXpCalculator._();

  static Future<int> compute({
    required AchievementsLocalRepository achievementsRepository,
    required AcademyProgressLocalRepository academyRepository,
  }) async {
    final unlockedAchievementIds = (await achievementsRepository.loadUnlocked()).keys.toSet();
    final achievementXp = AchievementCatalog.totalXpFor(unlockedAchievementIds);
    final academyXp = await academyRepository.totalXpEarned();
    return achievementXp + academyXp;
  }
}
