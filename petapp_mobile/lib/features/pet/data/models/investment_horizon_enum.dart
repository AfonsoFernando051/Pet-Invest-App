import 'package:flutter/material.dart';

/// How long the user expects to keep investing before needing the money
/// back, chosen during pet profile creation. Mirrors the onboarding
/// assessment's "horizonte de tempo" question, kept as a standalone
/// selection here rather than a scored risk input.
enum InvestmentHorizonEnum {
  shortTerm,
  mediumTerm,
  longTerm,
}

extension InvestmentHorizonEnumDisplay on InvestmentHorizonEnum {
  String get label => switch (this) {
        InvestmentHorizonEnum.shortTerm => 'Curto Prazo',
        InvestmentHorizonEnum.mediumTerm => 'Médio Prazo',
        InvestmentHorizonEnum.longTerm => 'Longo Prazo',
      };

  String get description => switch (this) {
        InvestmentHorizonEnum.shortTerm => 'Menos de 1 ano.',
        InvestmentHorizonEnum.mediumTerm => 'De 1 a 5 anos.',
        InvestmentHorizonEnum.longTerm => 'Mais de 5 anos.',
      };

  IconData get icon => switch (this) {
        InvestmentHorizonEnum.shortTerm => Icons.bolt,
        InvestmentHorizonEnum.mediumTerm => Icons.access_time,
        InvestmentHorizonEnum.longTerm => Icons.hourglass_bottom,
      };

  static InvestmentHorizonEnum fromName(String? name) {
    return InvestmentHorizonEnum.values.firstWhere(
      (h) => h.name == name,
      orElse: () => InvestmentHorizonEnum.mediumTerm,
    );
  }
}
