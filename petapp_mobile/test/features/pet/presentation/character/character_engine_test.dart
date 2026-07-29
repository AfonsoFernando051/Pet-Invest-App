import 'package:flutter_test/flutter_test.dart';
import 'package:petapp_mobile/features/pet/data/models/pet_specie_enum.dart';
import 'package:petapp_mobile/features/pet/domain/entities/pet_profile.dart';
import 'package:petapp_mobile/features/pet/domain/enums/accessory_type.dart';
import 'package:petapp_mobile/features/pet/domain/enums/character_emotion.dart';
import 'package:petapp_mobile/features/pet/domain/enums/pet_accessory_id.dart';
import 'package:petapp_mobile/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petapp_mobile/features/pet/domain/repositories/mascot_repository.dart';
import 'package:petapp_mobile/features/pet/domain/repositories/pet_repository.dart';
import 'package:petapp_mobile/features/pet/presentation/character/character_engine.dart';

class _FakeMascotRepository implements MascotRepository {
  _FakeMascotRepository(this.profileToReturn);

  PetProfile profileToReturn;

  @override
  Future<PetProfile> loadProfile() async => profileToReturn;

  @override
  Future<void> saveName(String name) async {}

  @override
  Future<void> saveStage(PetEvolutionStage stage) async {}

  @override
  Future<void> saveXp(int xp) async {}

  @override
  Future<void> saveNetWorth(double netWorth) async {}

  @override
  Future<void> saveEquippedAccessories(Map<AccessoryType, PetAccessoryId> equipped) async {}

  @override
  Future<void> saveUnlockedAccessories(Set<PetAccessoryId> unlocked) async {}

  @override
  Future<void> saveLastActiveAt(DateTime lastActiveAt) async {}
}

class _FakePetRepository implements PetRepository {
  _FakePetRepository({this.specieName});

  final String? specieName;

  @override
  Future<void> configurePet(PetSpecieEnum specie) async {}

  @override
  Future<bool> getPetStatus() async => true;

  @override
  Future<Map<String, dynamic>?> getMyPet() async =>
      specieName == null ? null : {'specie': specieName};
}

void main() {
  group('species hydration', () {
    test('corrects the mascot specie from PetRepository.getMyPet', () async {
      final mascotRepo = _FakeMascotRepository(PetProfile(specie: PetSpecieEnum.DOG));
      final engine = CharacterEngine(
        mascotRepository: mascotRepo,
        petRepository: _FakePetRepository(specieName: 'FOX'),
      );
      addTearDown(engine.dispose);

      await engine.loadProfile();

      expect(engine.profile.specie, PetSpecieEnum.FOX);
    });

    test('keeps the existing specie when PetRepository has no record', () async {
      final mascotRepo = _FakeMascotRepository(PetProfile(specie: PetSpecieEnum.DOG));
      final engine = CharacterEngine(
        mascotRepository: mascotRepo,
        petRepository: _FakePetRepository(specieName: null),
      );
      addTearDown(engine.dispose);

      await engine.loadProfile();

      expect(engine.profile.specie, PetSpecieEnum.DOG);
    });

    test('keeps the existing specie when no PetRepository is supplied', () async {
      final mascotRepo = _FakeMascotRepository(PetProfile(specie: PetSpecieEnum.DOG));
      final engine = CharacterEngine(mascotRepository: mascotRepo);
      addTearDown(engine.dispose);

      await engine.loadProfile();

      expect(engine.profile.specie, PetSpecieEnum.DOG);
    });
  });

  group('userReturned event', () {
    test('publishes a welcome-back line after a day away', () async {
      final now = DateTime(2026, 7, 29, 10);
      final mascotRepo = _FakeMascotRepository(
        PetProfile(specie: PetSpecieEnum.DOG, lastActiveAt: now.subtract(const Duration(days: 2))),
      );
      final engine = CharacterEngine(mascotRepository: mascotRepo);
      addTearDown(engine.dispose);

      await engine.loadProfile(now: now);
      await Future.delayed(Duration.zero);

      expect(engine.currentLine, isNotNull);
      expect(engine.emotion.emotion, CharacterEmotion.excited);
    });

    test('does not publish a welcome-back line on a same-day return', () async {
      final now = DateTime(2026, 7, 29, 10);
      final mascotRepo = _FakeMascotRepository(
        PetProfile(specie: PetSpecieEnum.DOG, lastActiveAt: now.subtract(const Duration(hours: 2))),
      );
      final engine = CharacterEngine(mascotRepository: mascotRepo);
      addTearDown(engine.dispose);

      await engine.loadProfile(now: now);
      await Future.delayed(Duration.zero);

      expect(engine.currentLine, isNull);
    });
  });

  group('evaluateEvolution delegation', () {
    test('publishes stageEvolved and a speech line when the tier increases', () async {
      final mascotRepo = _FakeMascotRepository(PetProfile(specie: PetSpecieEnum.DOG));
      final engine = CharacterEngine(mascotRepository: mascotRepo);
      addTearDown(engine.dispose);
      await engine.loadProfile();

      await engine.evaluateEvolution(2000, 300);
      await Future.delayed(Duration.zero);

      expect(engine.stage, PetEvolutionStage.adultDog);
      expect(engine.currentLine, isNotNull);
      expect(engine.emotion.emotion, CharacterEmotion.celebrating);
    });

    test('does not replay stageEvolved when the tier is unchanged', () async {
      final mascotRepo = _FakeMascotRepository(PetProfile(specie: PetSpecieEnum.DOG));
      final engine = CharacterEngine(mascotRepository: mascotRepo);
      addTearDown(engine.dispose);
      await engine.loadProfile();

      await engine.evaluateEvolution(2000, 300);
      await Future.delayed(Duration.zero);
      engine.emotion.setEmotion(CharacterEmotion.calm);

      await engine.evaluateEvolution(2100, 310);
      await Future.delayed(Duration.zero);

      expect(engine.stage, PetEvolutionStage.adultDog);
      expect(engine.emotion.emotion, CharacterEmotion.calm);
    });
  });
}
