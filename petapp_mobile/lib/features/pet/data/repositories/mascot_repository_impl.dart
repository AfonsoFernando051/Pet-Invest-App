import 'package:shared_preferences/shared_preferences.dart';
import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';
import 'package:petrimonium/features/pet/domain/entities/pet_profile.dart';
import 'package:petrimonium/features/pet/domain/enums/accessory_type.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_accessory_id.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petrimonium/features/pet/domain/repositories/mascot_repository.dart';

class MascotRepositoryImpl implements MascotRepository {
  static const _nameKey = 'mascot_name';
  static const _stageKey = 'mascot_stage';
  static const _xpKey = 'mascot_xp';
  static const _netWorthKey = 'mascot_net_worth';
  static const _equippedKeyPrefix = 'mascot_equipped_';
  static const _unlockedKey = 'mascot_unlocked_accessories';
  static const _lastActiveAtKey = 'mascot_last_active_at';

  @override
  Future<PetProfile> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    final name = prefs.getString(_nameKey);
    final stageName = prefs.getString(_stageKey);
    final stage = PetEvolutionStage.values.firstWhere(
      (s) => s.name == stageName,
      orElse: () => PetEvolutionStage.babyDog,
    );

    final xp = prefs.getInt(_xpKey) ?? 0;
    final netWorth = prefs.getDouble(_netWorthKey) ?? 0;

    final unlockedNames = prefs.getStringList(_unlockedKey) ?? const [];
    final unlocked = <PetAccessoryId>{
      for (final n in unlockedNames) ..._findAccessoryById(n),
    };

    final equipped = <AccessoryType, PetAccessoryId>{};
    for (final slot in AccessoryType.values) {
      final saved = prefs.getString('$_equippedKeyPrefix${slot.name}');
      if (saved == null) continue;
      final matches = _findAccessoryById(saved);
      if (matches.isNotEmpty) equipped[slot] = matches.first;
    }

    final lastActiveIso = prefs.getString(_lastActiveAtKey);
    final lastActiveAt =
        lastActiveIso != null ? DateTime.tryParse(lastActiveIso) : null;

    return PetProfile(
      specie: PetSpecieEnum.DOG,
      name: name,
      stage: stage,
      xp: xp,
      netWorth: netWorth,
      unlockedAccessories: unlocked,
      equippedAccessories: equipped,
      lastActiveAt: lastActiveAt ?? DateTime.now(),
    );
  }

  @override
  Future<void> saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
  }

  @override
  Future<void> saveStage(PetEvolutionStage stage) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_stageKey, stage.name);
  }

  @override
  Future<void> saveXp(int xp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_xpKey, xp);
  }

  @override
  Future<void> saveNetWorth(double netWorth) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_netWorthKey, netWorth);
  }

  @override
  Future<void> saveEquippedAccessories(
    Map<AccessoryType, PetAccessoryId> equipped,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    for (final slot in AccessoryType.values) {
      final key = '$_equippedKeyPrefix${slot.name}';
      final accessory = equipped[slot];
      if (accessory == null) {
        await prefs.remove(key);
      } else {
        await prefs.setString(key, accessory.name);
      }
    }
  }

  @override
  Future<void> saveUnlockedAccessories(Set<PetAccessoryId> unlocked) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _unlockedKey,
      unlocked.map((a) => a.name).toList(),
    );
  }

  @override
  Future<void> saveLastActiveAt(DateTime lastActiveAt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastActiveAtKey, lastActiveAt.toIso8601String());
  }
}

Iterable<PetAccessoryId> _findAccessoryById(String name) {
  return PetAccessoryId.values.where((a) => a.name == name);
}
