import 'package:flutter/material.dart';

/// The user's main investing objective, chosen during pet profile creation.
/// Mirrors the intent of the onboarding assessment's "principal objetivo"
/// question, but is a standalone selection here (not a scored risk input).
enum PetGoalEnum {
  preserveCapital,
  moderateGrowth,
  maximizeReturns,
  passiveIncome,
}

extension PetGoalEnumDisplay on PetGoalEnum {
  String get label => switch (this) {
        PetGoalEnum.preserveCapital => 'Preservar Capital',
        PetGoalEnum.moderateGrowth => 'Crescimento Moderado',
        PetGoalEnum.maximizeReturns => 'Maximizar Retornos',
        PetGoalEnum.passiveIncome => 'Renda Passiva',
      };

  String get description => switch (this) {
        PetGoalEnum.preserveCapital => 'Priorizar segurança e proteger o que já foi investido.',
        PetGoalEnum.moderateGrowth => 'Buscar um equilíbrio entre segurança e crescimento.',
        PetGoalEnum.maximizeReturns => 'Aceitar mais risco em troca de maior potencial de retorno.',
        PetGoalEnum.passiveIncome => 'Focar em ativos que geram renda recorrente.',
      };

  IconData get icon => switch (this) {
        PetGoalEnum.preserveCapital => Icons.shield_outlined,
        PetGoalEnum.moderateGrowth => Icons.trending_up,
        PetGoalEnum.maximizeReturns => Icons.rocket_launch,
        PetGoalEnum.passiveIncome => Icons.paid_outlined,
      };

  static PetGoalEnum fromName(String? name) {
    return PetGoalEnum.values.firstWhere(
      (g) => g.name == name,
      orElse: () => PetGoalEnum.moderateGrowth,
    );
  }
}
