import 'package:flutter/material.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/portfolio/domain/entities/achievement.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_stats.dart';
import 'package:petrimonium/features/portfolio/domain/services/passive_income_estimator.dart';

class _AchievementDef {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int xpReward;
  final bool Function(PortfolioStats) qualifies;

  const _AchievementDef({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.xpReward,
    required this.qualifies,
  });
}

/// The fixed, permanent achievement catalog. Per the project's stated rule
/// ("Achievements are permanent. Once unlocked, they cannot be removed."),
/// [resolve] never un-unlocks anything — the caller (`PortfolioController`)
/// is responsible for persisting [qualifiedIds] the first time they appear
/// and always union-ing with what was already persisted before.
///
/// Note: the original brief also mentions a "Global Investor" achievement,
/// but the backend's `InvestmentType` enum has no "international" category
/// to honestly evaluate that against — it's omitted here rather than faked.
class AchievementCatalog {
  const AchievementCatalog._();

  static final List<_AchievementDef> _defs = [
    _AchievementDef(
      id: 'first_investment',
      title: 'Primeiro Investimento',
      description: 'Registrou seu primeiro ativo no portfólio.',
      icon: Icons.flag_circle,
      xpReward: 50,
      qualifies: (s) => s.hasHoldings,
    ),
    _AchievementDef(
      id: 'first_dividend',
      title: 'Primeiro Dividendo',
      description: 'Possui ao menos um ativo com geração de renda passiva.',
      icon: Icons.attach_money,
      xpReward: 75,
      qualifies: (s) => PassiveIncomeEstimator.estimate(s).monthlyEstimate > 0,
    ),
    _AchievementDef(
      id: 'positive_return',
      title: 'Primeiro Lucro',
      description: 'Seu portfólio atingiu retorno positivo.',
      icon: Icons.trending_up,
      xpReward: 100,
      qualifies: (s) => s.summary.totalGain > 0,
    ),
    _AchievementDef(
      id: 'portfolio_10k',
      title: 'Patamar de R\$10 mil',
      description: 'Alcançou R\$10.000 em patrimônio investido.',
      icon: Icons.savings,
      xpReward: 150,
      qualifies: (s) => s.summary.currentValue >= 10000,
    ),
    _AchievementDef(
      id: 'portfolio_50k',
      title: 'Patamar de R\$50 mil',
      description: 'Alcançou R\$50.000 em patrimônio investido.',
      icon: Icons.account_balance,
      xpReward: 400,
      qualifies: (s) => s.summary.currentValue >= 50000,
    ),
    _AchievementDef(
      id: 'diversification_master',
      title: 'Mestre da Diversificação',
      description: 'Investiu em 4 ou mais categorias de ativos.',
      icon: Icons.hub,
      xpReward: 200,
      qualifies: (s) => s.distinctTypeCount >= 4,
    ),
    _AchievementDef(
      id: 'etf_collector',
      title: 'Colecionador de ETFs',
      description: 'Reuniu 3 ou mais ETFs/fundos distintos.',
      icon: Icons.pie_chart,
      xpReward: 150,
      qualifies: (s) => s.holdings.where((h) => h.type == InvestmentTypeEnum.FUNDS).length >= 3,
    ),
    _AchievementDef(
      id: 'hundred_days',
      title: '100 Dias Investindo',
      description: 'Manteve investimentos ativos por 100 dias.',
      icon: Icons.calendar_month,
      xpReward: 200,
      qualifies: (s) {
        final first = s.firstPurchaseDate;
        return first != null && DateTime.now().difference(first).inDays >= 100;
      },
    ),
    _AchievementDef(
      id: 'long_term_investor',
      title: 'Investidor de Longo Prazo',
      description: 'Manteve investimentos ativos por 1 ano.',
      icon: Icons.emoji_events,
      xpReward: 500,
      qualifies: (s) {
        final first = s.firstPurchaseDate;
        return first != null && DateTime.now().difference(first).inDays >= 365;
      },
    ),
    _AchievementDef(
      id: 'dividend_hunter',
      title: 'Caçador de Dividendos',
      description: 'Alcançou R\$1.000/ano em renda passiva estimada.',
      icon: Icons.paid,
      xpReward: 250,
      qualifies: (s) => PassiveIncomeEstimator.estimate(s).annualEstimate >= 1000,
    ),
  ];

  /// XP granted for every achievement unlocked so far — the single source
  /// feeding `MascotController.evaluateEvolution`'s `userXp` parameter.
  static int totalXpFor(Set<String> unlockedIds) {
    return _defs.where((d) => unlockedIds.contains(d.id)).fold(0, (sum, d) => sum + d.xpReward);
  }

  /// IDs whose condition is met *right now* — the caller persists any of
  /// these not already in its stored unlocked set.
  static Set<String> qualifiedIds(PortfolioStats stats) {
    return _defs.where((d) => d.qualifies(stats)).map((d) => d.id).toSet();
  }

  /// Builds the full display list, `unlocked` sourced from persisted state
  /// only (never re-derived live), so a later dip in net worth can't hide an
  /// achievement already earned.
  static List<Achievement> resolve(Map<String, DateTime> unlockedAt) {
    return _defs
        .map((d) => Achievement(
              id: d.id,
              title: d.title,
              description: d.description,
              icon: d.icon,
              xpReward: d.xpReward,
              unlocked: unlockedAt.containsKey(d.id),
              unlockedAt: unlockedAt[d.id],
            ))
        .toList();
  }
}
