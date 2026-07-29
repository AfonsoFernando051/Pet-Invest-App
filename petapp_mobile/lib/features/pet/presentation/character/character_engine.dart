import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:petapp_mobile/features/pet/data/models/pet_specie_enum.dart';
import 'package:petapp_mobile/features/pet/domain/character/character_event.dart';
import 'package:petapp_mobile/features/pet/domain/entities/pet_accessory.dart';
import 'package:petapp_mobile/features/pet/domain/entities/pet_evolution_rule.dart';
import 'package:petapp_mobile/features/pet/domain/entities/pet_profile.dart';
import 'package:petapp_mobile/features/pet/domain/enums/accessory_type.dart';
import 'package:petapp_mobile/features/pet/domain/enums/pet_accessory_id.dart';
import 'package:petapp_mobile/features/pet/domain/enums/pet_animation_state.dart';
import 'package:petapp_mobile/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petapp_mobile/features/pet/domain/repositories/mascot_repository.dart';
import 'package:petapp_mobile/features/pet/domain/repositories/pet_repository.dart';
import 'package:petapp_mobile/features/pet/presentation/character/character_emotion_controller.dart';
import 'package:petapp_mobile/features/pet/presentation/character/character_event_bus.dart';
import 'package:petapp_mobile/features/pet/presentation/character/idle_behavior_controller.dart';
import 'package:petapp_mobile/features/pet/presentation/character/interaction_controller.dart';
import 'package:petapp_mobile/features/pet/presentation/character/personality_engine.dart';
import 'package:petapp_mobile/features/pet/presentation/character/relationship_engine.dart';
import 'package:petapp_mobile/features/pet/presentation/mascot/controllers/mascot_controller.dart';

/// The Character Engine façade: composes the Animation/Behavior backbone
/// (`MascotController`, unchanged) with the new Emotion, Behavior (idle),
/// Personality, Relationship and Event Reaction subsystems, so screens
/// depend on one living character instead of wiring each subsystem by hand.
///
/// Every existing `MascotController` getter/method is re-exposed here so
/// current call sites (`dashboard_screen.dart`, `PortfolioController`,
/// `RpgIntegrationCard`) can swap `MascotController` → `CharacterEngine` as
/// a type change, not a rewrite. See docs/CHARACTER_ENGINE.md for the full
/// subsystem map and what's still Phase 1+ (AI Brain, Speech, Lip Sync).
class CharacterEngine extends ChangeNotifier {
  CharacterEngine({
    required MascotRepository mascotRepository,
    this.petRepository,
    PersonalityEngine? personalityEngine,
    RelationshipEngine? relationshipEngine,
    List<PetEvolutionRule> evolutionRules = PetEvolutionRule.defaultRules,
  })  : _mascotRepository = mascotRepository,
        mascot = MascotController(repository: mascotRepository, evolutionRules: evolutionRules),
        emotion = CharacterEmotionController(),
        idle = IdleBehaviorController(),
        personality = personalityEngine ?? const DefaultPersonalityEngine(),
        relationship = relationshipEngine ?? const RelationshipEngine(),
        eventBus = CharacterEventBus() {
    interaction = InteractionController(mascot: mascot, emotion: emotion);
    mascot.addListener(_onMascotChanged);
    emotion.addListener(notifyListeners);
    idle.addListener(notifyListeners);
    _eventSubscription = eventBus.events.listen(_handleEvent);
  }

  final MascotRepository _mascotRepository;

  /// Owns the user's real species choice server-side. Optional purely so
  /// this class stays constructible in tests without a network dependency;
  /// when omitted, species hydration is skipped and whatever
  /// `MascotRepository` already has is kept.
  final PetRepository? petRepository;

  final MascotController mascot;
  final CharacterEmotionController emotion;
  final IdleBehaviorController idle;
  final PersonalityEngine personality;
  final RelationshipEngine relationship;
  final CharacterEventBus eventBus;

  /// Interaction Controller subsystem — `CharacterWidget`'s gesture handlers
  /// call through this instead of manipulating `mascot`/`emotion` directly.
  late final InteractionController interaction;

  late final StreamSubscription<CharacterEvent> _eventSubscription;
  Timer? _lineTimer;
  String? _currentLine;

  /// A transient, template-authored line the mascot is currently "saying" —
  /// shown by `CharacterSpeechBubble`. Cleared automatically after a few
  /// seconds. Phase 1+ will generate this via `AiBrain` instead of
  /// `PersonalityEngine` templates; nothing else about this API changes.
  String? get currentLine => _currentLine;

  // ── Delegated MascotController surface ──────────────────────────────────
  PetProfile get profile => mascot.profile;
  PetAnimationState get animationState => mascot.animationState;
  PetEvolutionStage get stage => mascot.stage;
  bool get isLoading => mascot.isLoading;

  PetEvolutionStage resolveStage({required double currentNetWorth, required int userXp}) =>
      mascot.resolveStage(currentNetWorth: currentNetWorth, userXp: userXp);

  Future<void> evaluateEvolution(double currentNetWorth, int userXp) async {
    final previousStage = mascot.stage;
    await mascot.evaluateEvolution(currentNetWorth, userXp);
    if (mascot.stage.tier > previousStage.tier) {
      publish(const CharacterEvent(CharacterEventType.stageEvolved));
    }
  }

  void triggerEventAnimation(
    PetAnimationState state, {
    Duration duration = const Duration(seconds: 3),
  }) =>
      mascot.triggerEventAnimation(state, duration: duration);

  Future<void> unlockAccessory(PetAccessoryId id) => mascot.unlockAccessory(id);

  Future<void> equipAccessory(PetAccessory accessory) => mascot.equipAccessory(accessory);

  Future<void> unequipAccessory(AccessoryType type) => mascot.unequipAccessory(type);

  // ── Character Engine orchestration ──────────────────────────────────────

  /// Loads the mascot profile, corrects its species from the real backend
  /// record (fixing `MascotRepositoryImpl`'s hardcoded `DOG` default),
  /// starts the idle behavior cycle, and — if the player was away for at
  /// least a day — publishes [CharacterEventType.userReturned].
  Future<void> loadProfile({DateTime? now}) async {
    final currentTime = now ?? DateTime.now();
    final previousLastActiveAt = await _peekPreviousLastActiveAt();

    await mascot.loadProfile(now: currentTime);
    await _hydrateSpecies();

    idle.start();
    idle.onAnimationStateChanged(mascot.animationState);

    if (previousLastActiveAt != null) {
      final moment = relationship.evaluate(lastActiveAt: previousLastActiveAt, now: currentTime);
      if (moment.type == RelationshipMomentType.welcomeBack) {
        publish(CharacterEvent(
          CharacterEventType.userReturned,
          payload: {'daysAway': moment.daysAway},
        ));
      }
    }
  }

  /// Reads `lastActiveAt` as it was *before* this session — `mascot.
  /// loadProfile` immediately overwrites it with `now`, so it must be read
  /// beforehand to know how long the player was actually away.
  Future<DateTime?> _peekPreviousLastActiveAt() async {
    try {
      final previous = await _mascotRepository.loadProfile();
      return previous.lastActiveAt;
    } catch (_) {
      return null;
    }
  }

  Future<void> _hydrateSpecies() async {
    final repo = petRepository;
    if (repo == null) return;
    try {
      final data = await repo.getMyPet();
      final species = _parseSpecie(data?['specie']);
      if (species != null) {
        mascot.updateSpecie(species);
      }
    } catch (_) {
      // Non-critical — keep whatever specie the local mascot record has.
    }
  }

  static PetSpecieEnum? _parseSpecie(Object? raw) {
    if (raw is! String) return null;
    for (final species in PetSpecieEnum.values) {
      if (species.name.toUpperCase() == raw.toUpperCase()) return species;
    }
    return null;
  }

  /// Publishes a [CharacterEvent] for any subsystem (currently: this
  /// engine's own emotion/speech reaction) subscribed to [eventBus].
  void publish(CharacterEvent event) => eventBus.publish(event);

  void _onMascotChanged() {
    idle.onAnimationStateChanged(mascot.animationState);
    notifyListeners();
  }

  void _handleEvent(CharacterEvent event) {
    emotion.reactTo(event.type);

    final line = switch (event.type) {
      CharacterEventType.userReturned => personality.greetingFor(
          mascot.profile.specie,
          daysAway: (event.payload['daysAway'] as int?) ?? 1,
          petName: mascot.profile.name,
        ),
      CharacterEventType.achievementUnlocked ||
      CharacterEventType.stageEvolved ||
      CharacterEventType.missionCompleted =>
        personality.phraseFor(event.type, mascot.profile.specie),
      // Phase 1+ event types — not published yet, nothing to say.
      _ => null,
    };

    if (line != null) _showLine(line);
  }

  void _showLine(String line) {
    _lineTimer?.cancel();
    _currentLine = line;
    notifyListeners();
    _lineTimer = Timer(const Duration(seconds: 4), () {
      _currentLine = null;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _lineTimer?.cancel();
    _eventSubscription.cancel();
    mascot.removeListener(_onMascotChanged);
    mascot.dispose();
    emotion.dispose();
    idle.dispose();
    eventBus.dispose();
    super.dispose();
  }
}
