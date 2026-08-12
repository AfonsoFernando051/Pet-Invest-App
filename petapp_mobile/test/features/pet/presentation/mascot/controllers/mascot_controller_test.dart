import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_accessory.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_profile.dart';
import 'package:petrimonium/features/pet/domain/enums/accessory_type.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_accessory_id.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_animation_state.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petrimonium/features/pet/domain/repositories/mascot_repository.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';

/// In-memory [MascotRepository] double: records every persisted write so
/// tests can assert on exactly what MascotController chose to save.
class FakeMascotRepository implements MascotRepository {
  PetEvolutionStage? savedStage;
  int savedStageCalls = 0;
  int? savedXp;
  double? savedNetWorth;
  Map<AccessoryType, PetAccessoryId>? savedEquipped;
  Set<PetAccessoryId>? savedUnlocked;
  DateTime? savedLastActiveAt;

  PetProfile profileToReturn = PetProfile();
  String? savedName;

  @override
  Future<PetProfile> loadProfile() async => profileToReturn;

  @override
  Future<void> saveName(String name) async => savedName = name;

  @override
  Future<void> saveStage(PetEvolutionStage stage) async {
    savedStage = stage;
    savedStageCalls++;
  }

  @override
  Future<void> saveXp(int xp) async => savedXp = xp;

  @override
  Future<void> saveNetWorth(double netWorth) async => savedNetWorth = netWorth;

  @override
  Future<void> saveEquippedAccessories(
    Map<AccessoryType, PetAccessoryId> equipped,
  ) async =>
      savedEquipped = equipped;

  @override
  Future<void> saveUnlockedAccessories(Set<PetAccessoryId> unlocked) async =>
      savedUnlocked = unlocked;

  @override
  Future<void> saveLastActiveAt(DateTime lastActiveAt) async =>
      savedLastActiveAt = lastActiveAt;
}

void main() {
  late FakeMascotRepository repository;
  late MascotController controller;

  setUp(() {
    repository = FakeMascotRepository();
    controller = MascotController(repository: repository);
  });

  tearDown(() => controller.dispose());

  group('resolveStage — financial thresholds map to the 9 evolution tiers', () {
    const cases = <(PetEvolutionStage, double, int)>[
      (PetEvolutionStage.babyDog, 0, 0),
      (PetEvolutionStage.teenDog, 500, 100),
      (PetEvolutionStage.adultDog, 2000, 300),
      (PetEvolutionStage.masterDog, 5000, 600),
      (PetEvolutionStage.legendaryDog, 15000, 1200),
      (PetEvolutionStage.royalDog, 40000, 2500),
      (PetEvolutionStage.cyberMysticDog, 100000, 5000),
      (PetEvolutionStage.cosmicGuardianDog, 250000, 10000),
      (PetEvolutionStage.goldenFinanceDog, 500000, 20000),
    ];

    for (final (stage, netWorth, xp) in cases) {
      test('reaching exactly the ${stage.name} threshold resolves to ${stage.name}', () {
        final resolved = controller.resolveStage(currentNetWorth: netWorth, userXp: xp);
        expect(resolved, stage);
      });
    }

    test('there are exactly 9 stages and each has a strictly higher tier than the previous', () {
      expect(PetEvolutionStage.values.length, 9);
      for (var i = 1; i < PetEvolutionStage.values.length; i++) {
        expect(
          PetEvolutionStage.values[i].tier,
          greaterThan(PetEvolutionStage.values[i - 1].tier),
        );
      }
    });

    test('just below a threshold resolves to the previous tier', () {
      final resolved = controller.resolveStage(currentNetWorth: 499.99, userXp: 100);
      expect(resolved, PetEvolutionStage.babyDog);
    });

    test('high net worth alone does not skip tiers if XP requirement is unmet', () {
      final resolved = controller.resolveStage(currentNetWorth: 500000, userXp: 0);
      expect(resolved, PetEvolutionStage.babyDog);
    });

    test('high XP alone does not skip tiers if net worth requirement is unmet', () {
      final resolved = controller.resolveStage(currentNetWorth: 0, userXp: 20000);
      expect(resolved, PetEvolutionStage.babyDog);
    });
  });

  group('evaluateEvolution', () {
    test('upgrades stage, persists it and plays the victory animation on crossing a tier', () async {
      await controller.evaluateEvolution(2000, 300);

      expect(controller.stage, PetEvolutionStage.adultDog);
      expect(controller.animationState, PetAnimationState.victory);
      expect(repository.savedStage, PetEvolutionStage.adultDog);
      expect(repository.savedNetWorth, 2000);
      expect(repository.savedXp, 300);
    });

    test('does not persist a stage change or replay victory when the tier is unchanged', () async {
      await controller.evaluateEvolution(2000, 300);
      repository.savedStageCalls = 0;
      controller.triggerEventAnimation(PetAnimationState.idle, duration: Duration.zero);

      await controller.evaluateEvolution(2100, 310);

      expect(controller.stage, PetEvolutionStage.adultDog);
      expect(repository.savedStageCalls, 0);
      expect(controller.animationState, isNot(PetAnimationState.victory));
    });

    test('never downgrades the stage when net worth later drops', () async {
      await controller.evaluateEvolution(40000, 2500);
      expect(controller.stage, PetEvolutionStage.royalDog);

      await controller.evaluateEvolution(100, 50);

      expect(controller.stage, PetEvolutionStage.royalDog);
      expect(repository.savedStageCalls, 1);
    });

    test('evolving all the way to the final prestige tier', () async {
      await controller.evaluateEvolution(500000, 20000);
      expect(controller.stage, PetEvolutionStage.goldenFinanceDog);
      expect(controller.stage.tier, 9);
    });
  });

  group('triggerEventAnimation', () {
    test('overrides the animation immediately and reverts after the given duration', () async {
      controller.triggerEventAnimation(
        PetAnimationState.celebrate,
        duration: Duration.zero,
      );
      expect(controller.animationState, PetAnimationState.celebrate);

      await Future.delayed(Duration.zero);
      expect(controller.animationState, PetAnimationState.idle);
    });
  });

  group('equipAccessory / unequipAccessory', () {
    test('equipping a locked accessory throws', () {
      expect(
        () => controller.equipAccessory(
          const PetAccessory(id: PetAccessoryId.baseballCap),
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('unlocking then equipping persists the accessory in its slot', () async {
      await controller.unlockAccessory(PetAccessoryId.baseballCap);
      await controller.equipAccessory(
        const PetAccessory(id: PetAccessoryId.baseballCap, unlocked: true),
      );

      expect(controller.profile.equippedAccessories[AccessoryType.headwear],
          PetAccessoryId.baseballCap);
      expect(repository.savedEquipped?[AccessoryType.headwear],
          PetAccessoryId.baseballCap);
    });

    test('unequipping clears the slot', () async {
      await controller.unlockAccessory(PetAccessoryId.baseballCap);
      await controller.equipAccessory(
        const PetAccessory(id: PetAccessoryId.baseballCap, unlocked: true),
      );

      await controller.unequipAccessory(AccessoryType.headwear);

      expect(controller.profile.equippedAccessories.containsKey(AccessoryType.headwear), isFalse);
      expect(repository.savedEquipped?.containsKey(AccessoryType.headwear), isFalse);
    });
  });
}
