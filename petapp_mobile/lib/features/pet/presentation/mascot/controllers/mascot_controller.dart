import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:petapp_mobile/features/pet/data/models/pet_specie_enum.dart';
import 'package:petapp_mobile/features/pet/domain/entities/pet_accessory.dart';
import 'package:petapp_mobile/features/pet/domain/entities/pet_evolution_rule.dart';
import 'package:petapp_mobile/features/pet/domain/entities/pet_profile.dart';
import 'package:petapp_mobile/features/pet/domain/enums/accessory_type.dart';
import 'package:petapp_mobile/features/pet/domain/enums/pet_accessory_id.dart';
import 'package:petapp_mobile/features/pet/domain/enums/pet_animation_state.dart';
import 'package:petapp_mobile/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petapp_mobile/features/pet/domain/repositories/mascot_repository.dart';

/// After this many days without a session, the mascot rests in [sleep]
/// instead of its usual idle loop.
const int kSleepAfterInactiveDays = 3;

/// Local hours (0-23, device time) during which the mascot is considered to
/// be sleeping even on an active day.
const int kNightStartHour = 0;
const int kNightEndHour = 6;

/// Reactive state holder for the pet mascot: current [PetProfile], transient
/// event-driven animation overrides, and the financial-progress → evolution
/// mapping.
class MascotController extends ChangeNotifier {
  MascotController({
    required MascotRepository repository,
    List<PetEvolutionRule> evolutionRules = PetEvolutionRule.defaultRules,
  })  : _repository = repository,
        _rules = _sortedDescending(evolutionRules),
        _profile = PetProfile();

  final MascotRepository _repository;
  final List<PetEvolutionRule> _rules;

  PetProfile _profile;
  Timer? _revertTimer;
  bool _loading = false;

  PetProfile get profile => _profile;
  PetAnimationState get animationState => _profile.animationState;
  PetEvolutionStage get stage => _profile.stage;
  bool get isLoading => _loading;

  static List<PetEvolutionRule> _sortedDescending(List<PetEvolutionRule> rules) {
    final sorted = List<PetEvolutionRule>.of(rules);
    sorted.sort((a, b) => b.stage.tier.compareTo(a.stage.tier));
    return sorted;
  }

  /// Loads the persisted profile, resolves whether the mascot should be
  /// resting ([PetAnimationState.sleep]) based on inactivity, then records
  /// this session as "now".
  Future<void> loadProfile({DateTime? now}) async {
    _loading = true;
    notifyListeners();

    final loaded = await _repository.loadProfile();
    final currentTime = now ?? DateTime.now();
    final restingState = restingStateFor(
      lastActiveAt: loaded.lastActiveAt,
      now: currentTime,
    );

    _profile = loaded.copyWith(
      animationState: restingState,
      lastActiveAt: currentTime,
    );
    _loading = false;
    notifyListeners();

    await _repository.saveLastActiveAt(currentTime);
  }

  /// The animation the mascot should idle in when there is no active event
  /// override, purely a function of when it was last opened.
  static PetAnimationState restingStateFor({
    required DateTime lastActiveAt,
    required DateTime now,
  }) {
    final daysSinceActive = now.difference(lastActiveAt).inDays;
    if (daysSinceActive >= kSleepAfterInactiveDays) {
      return PetAnimationState.sleep;
    }
    if (now.hour >= kNightStartHour && now.hour < kNightEndHour) {
      return PetAnimationState.sleep;
    }
    return PetAnimationState.idle;
  }

  /// Temporarily overrides the mascot's animation (e.g. `celebrate` when the
  /// user makes a new investment), then gracefully reverts to the resting
  /// state once [duration] elapses.
  void triggerEventAnimation(
    PetAnimationState state, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _revertTimer?.cancel();
    _profile = _profile.copyWith(animationState: state);
    notifyListeners();

    _revertTimer = Timer(duration, () {
      _profile = _profile.copyWith(
        animationState: restingStateFor(
          lastActiveAt: _profile.lastActiveAt,
          now: DateTime.now(),
        ),
      );
      notifyListeners();
    });
  }

  /// Returns the highest [PetEvolutionStage] whose rule is satisfied by
  /// [currentNetWorth] and [userXp]. Rules are evaluated from strongest to
  /// weakest; [PetEvolutionRule.defaultRules] guarantees `babyDog` (0/0) is
  /// always satisfied, so this never returns null.
  PetEvolutionStage resolveStage({
    required double currentNetWorth,
    required int userXp,
  }) {
    for (final rule in _rules) {
      if (rule.isSatisfiedBy(netWorth: currentNetWorth, xp: userXp)) {
        return rule.stage;
      }
    }
    return PetEvolutionStage.babyDog;
  }

  /// Checks the evolution rules against the user's latest financial state
  /// and, if a higher tier has been unlocked, upgrades the mascot and plays
  /// the `victory` animation.
  Future<void> evaluateEvolution(double currentNetWorth, int userXp) async {
    final resolvedStage = resolveStage(
      currentNetWorth: currentNetWorth,
      userXp: userXp,
    );
    // Evolution never regresses: a temporary dip in net worth (e.g. a
    // withdrawal) must not strip a tier the user already earned.
    final didEvolve = resolvedStage.tier > _profile.stage.tier;
    final targetStage = didEvolve ? resolvedStage : _profile.stage;

    _profile = _profile.copyWith(
      stage: targetStage,
      netWorth: currentNetWorth,
      xp: userXp,
    );
    notifyListeners();

    await _repository.saveNetWorth(currentNetWorth);
    await _repository.saveXp(userXp);
    if (didEvolve) {
      await _repository.saveStage(targetStage);
      triggerEventAnimation(PetAnimationState.victory, duration: const Duration(seconds: 4));
    }
  }

  Future<void> unlockAccessory(PetAccessoryId id) async {
    if (_profile.unlockedAccessories.contains(id)) return;
    final unlocked = {..._profile.unlockedAccessories, id};
    _profile = _profile.copyWith(unlockedAccessories: unlocked);
    notifyListeners();
    await _repository.saveUnlockedAccessories(unlocked);
  }

  /// Equips [accessory] in its slot, replacing whatever was equipped there.
  /// Throws a [StateError] if the accessory hasn't been unlocked yet.
  Future<void> equipAccessory(PetAccessory accessory) async {
    if (!_profile.unlockedAccessories.contains(accessory.id)) {
      throw StateError('Cannot equip a locked accessory: ${accessory.id}');
    }

    final equipped = {..._profile.equippedAccessories};
    equipped[accessory.type] = accessory.id;
    _profile = _profile.copyWith(equippedAccessories: equipped);
    notifyListeners();

    await _repository.saveEquippedAccessories(equipped);
  }

  /// Corrects the mascot's specie from the real backend record. Species
  /// selection is owned by `PetRepository` (server-backed), not by this
  /// controller's `MascotRepository` (local-prefs, gamification-only) — see
  /// `CharacterEngine._hydrateSpecies`, which calls this after
  /// `PetRepository.getMyPet()` resolves.
  void updateSpecie(PetSpecieEnum specie) {
    if (_profile.specie == specie) return;
    _profile = _profile.copyWith(specie: specie);
    notifyListeners();
  }

  Future<void> unequipAccessory(AccessoryType type) async {
    if (!_profile.equippedAccessories.containsKey(type)) return;

    final equipped = {..._profile.equippedAccessories}..remove(type);
    _profile = _profile.copyWith(equippedAccessories: equipped);
    notifyListeners();

    await _repository.saveEquippedAccessories(equipped);
  }

  @override
  void dispose() {
    _revertTimer?.cancel();
    super.dispose();
  }
}
