import 'package:shared_preferences/shared_preferences.dart';
import 'package:petrimonium/features/academy/domain/services/academy_catalog.dart';

/// Persists completed Academy lesson ids on-device. Mirrors
/// `AchievementsLocalRepository`'s style exactly: entries are only ever
/// added, never removed — completing a lesson is permanent, like unlocking
/// an achievement.
class AcademyProgressLocalRepository {
  static const _completedLessonIdsKey = 'academy_completed_lesson_ids';

  Future<Set<String>> loadCompletedLessonIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_completedLessonIdsKey) ?? const []).toSet();
  }

  /// Adds [lessonId] to whatever was already persisted. A no-op if the
  /// lesson was already completed (replaying a lesson never re-grants XP).
  Future<Set<String>> markLessonCompleted(String lessonId) async {
    final existing = await loadCompletedLessonIds();
    if (existing.contains(lessonId)) return existing;

    final merged = {...existing, lessonId};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_completedLessonIdsKey, merged.toList());
    return merged;
  }

  Future<int> totalXpEarned() async {
    return AcademyCatalog.xpEarnedFor(await loadCompletedLessonIds());
  }
}
