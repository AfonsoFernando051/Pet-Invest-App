import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petrimonium/features/portfolio/domain/entities/achievement.dart';

/// Something the Financial Engine or Game Engine did that other systems
/// (character reactions, notifications, a future AI Mentor) may want to
/// react to, without being called directly by whatever emitted it.
///
/// Kept intentionally small: only the events this codebase can honestly emit
/// today. Add a case when a real trigger exists for it, not in advance of one.
sealed class AppEvent {
  const AppEvent();
}

/// Fired the moment a permanent achievement is unlocked (see
/// `AchievementCatalog` — achievements never re-lock).
class AchievementUnlockedEvent extends AppEvent {
  final Achievement achievement;
  const AchievementUnlockedEvent(this.achievement);
}

/// Fired when the pet's evolution tier advances (see
/// `MascotController.evaluateEvolution`).
class PetEvolvedEvent extends AppEvent {
  final PetEvolutionStage newStage;
  const PetEvolvedEvent(this.newStage);
}

/// Fired when the player's computed level (see `LevelCalculator`) increases.
class UserLeveledUpEvent extends AppEvent {
  final int newLevel;
  const UserLeveledUpEvent(this.newLevel);
}
