import 'package:shared_preferences/shared_preferences.dart';

/// Persists unlocked achievement ids + their unlock timestamp on-device.
/// Mirrors `MascotRepositoryImpl`'s SharedPreferences-backed style. Entries
/// are only ever added, never removed, matching the project's "achievements
/// are permanent" rule.
class AchievementsLocalRepository {
  static const _idsKey = 'achievements_unlocked_ids';
  static const _datesKey = 'achievements_unlocked_dates';

  Future<Map<String, DateTime>> loadUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_idsKey) ?? const [];
    final dates = prefs.getStringList(_datesKey) ?? const [];

    final result = <String, DateTime>{};
    for (var i = 0; i < ids.length && i < dates.length; i++) {
      final parsed = DateTime.tryParse(dates[i]);
      if (parsed != null) result[ids[i]] = parsed;
    }
    return result;
  }

  /// Adds [newlyUnlockedIds] (unlocked "now") to whatever was already
  /// persisted and returns the merged map.
  Future<Map<String, DateTime>> unlockAll(Set<String> newlyUnlockedIds) async {
    final existing = await loadUnlocked();
    if (newlyUnlockedIds.isEmpty) return existing;

    final now = DateTime.now();
    final merged = {...existing};
    for (final id in newlyUnlockedIds) {
      merged.putIfAbsent(id, () => now);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_idsKey, merged.keys.toList());
    await prefs.setStringList(_datesKey, merged.values.map((d) => d.toIso8601String()).toList());
    return merged;
  }
}
