import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';

/// The financial thresholds a user must reach to unlock [stage].
///
/// A rule is satisfied when the user's net worth *and* accumulated XP (from
/// good financial habits — deposits, on-time contributions, diversification,
/// etc.) both meet or exceed their respective minimums. Requiring both
/// avoids rewarding pure wealth without engagement, or pure engagement
/// without real financial progress.
class PetEvolutionRule {
  final PetEvolutionStage stage;
  final double minNetWorth;
  final int minXp;

  const PetEvolutionRule({
    required this.stage,
    required this.minNetWorth,
    required this.minXp,
  });

  bool isSatisfiedBy({required double netWorth, required int xp}) {
    return netWorth >= minNetWorth && xp >= minXp;
  }

  PetEvolutionRule copyWith({
    PetEvolutionStage? stage,
    double? minNetWorth,
    int? minXp,
  }) {
    return PetEvolutionRule(
      stage: stage ?? this.stage,
      minNetWorth: minNetWorth ?? this.minNetWorth,
      minXp: minXp ?? this.minXp,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetEvolutionRule &&
          runtimeType == other.runtimeType &&
          stage == other.stage &&
          minNetWorth == other.minNetWorth &&
          minXp == other.minXp;

  @override
  int get hashCode => Object.hash(stage, minNetWorth, minXp);

  @override
  String toString() =>
      'PetEvolutionRule(stage: $stage, minNetWorth: $minNetWorth, minXp: $minXp)';

  /// Default tier progression, ordered weakest to strongest. Kept as the
  /// single source of truth for `MascotController.evaluateEvolution`.
  static const List<PetEvolutionRule> defaultRules = [
    PetEvolutionRule(stage: PetEvolutionStage.babyDog, minNetWorth: 0, minXp: 0),
    PetEvolutionRule(stage: PetEvolutionStage.teenDog, minNetWorth: 500, minXp: 100),
    PetEvolutionRule(stage: PetEvolutionStage.adultDog, minNetWorth: 2000, minXp: 300),
    PetEvolutionRule(stage: PetEvolutionStage.masterDog, minNetWorth: 5000, minXp: 600),
    PetEvolutionRule(stage: PetEvolutionStage.legendaryDog, minNetWorth: 15000, minXp: 1200),
    PetEvolutionRule(stage: PetEvolutionStage.royalDog, minNetWorth: 40000, minXp: 2500),
    PetEvolutionRule(stage: PetEvolutionStage.cyberMysticDog, minNetWorth: 100000, minXp: 5000),
    PetEvolutionRule(stage: PetEvolutionStage.cosmicGuardianDog, minNetWorth: 250000, minXp: 10000),
    PetEvolutionRule(stage: PetEvolutionStage.goldenFinanceDog, minNetWorth: 500000, minXp: 20000),
  ];
}
