import 'package:flutter/material.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/portfolio/domain/entities/mission.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_stats.dart';
import 'package:petrimonium/features/portfolio/domain/services/passive_income_estimator.dart';

/// Resolves the fixed mission catalog against a real [PortfolioStats]
/// snapshot. Missions are re-evaluated on every load (they're meant to be
/// short/medium-term goals, unlike the permanent [AchievementCatalog]).
class MissionCatalog {
  const MissionCatalog._();

  static List<Mission> evaluate(PortfolioStats stats) {
    final income = PassiveIncomeEstimator.estimate(stats);
    final firstPurchase = stats.firstPurchaseDate;
    final daysInvesting = firstPurchase == null ? 0 : DateTime.now().difference(firstPurchase).inDays;
    final fundsCount = stats.holdings.where((h) => h.type == InvestmentTypeEnum.FUNDS).length;

    return [
      Mission(
        id: 'first_investment',
        title: 'Primeiro Investimento',
        description: 'Registre seu primeiro ativo no portfólio.',
        icon: Icons.flag_circle,
        current: stats.hasHoldings ? 1 : 0,
        target: 1,
        xpReward: 50,
      ),
      Mission(
        id: 'portfolio_10k',
        title: 'Portfólio acima de R\$10 mil',
        description: 'Alcance R\$10.000 em patrimônio investido.',
        icon: Icons.savings,
        current: stats.summary.currentValue,
        target: 10000,
        xpReward: 150,
      ),
      Mission(
        id: 'portfolio_50k',
        title: 'Portfólio acima de R\$50 mil',
        description: 'Alcance R\$50.000 em patrimônio investido.',
        icon: Icons.account_balance,
        current: stats.summary.currentValue,
        target: 50000,
        xpReward: 400,
      ),
      Mission(
        id: 'diversification_master',
        title: 'Mestre da Diversificação',
        description: 'Invista em pelo menos 4 categorias de ativos diferentes.',
        icon: Icons.hub,
        current: stats.distinctTypeCount.toDouble(),
        target: 4,
        xpReward: 200,
      ),
      Mission(
        id: 'etf_collector',
        title: 'Colecionador de ETFs',
        description: 'Tenha 3 ou mais ETFs/fundos distintos na carteira.',
        icon: Icons.pie_chart,
        current: fundsCount.toDouble(),
        target: 3,
        xpReward: 150,
      ),
      Mission(
        id: 'hundred_days',
        title: '100 Dias Investindo',
        description: 'Mantenha investimentos ativos por 100 dias.',
        icon: Icons.calendar_month,
        current: daysInvesting.toDouble(),
        target: 100,
        xpReward: 200,
      ),
      Mission(
        id: 'long_term_investor',
        title: 'Investidor de Longo Prazo',
        description: 'Mantenha investimentos ativos por 1 ano.',
        icon: Icons.emoji_events,
        current: daysInvesting.toDouble(),
        target: 365,
        xpReward: 500,
      ),
      Mission(
        id: 'dividend_hunter',
        title: 'Caçador de Dividendos',
        description: 'Alcance R\$1.000/ano em renda passiva estimada.',
        icon: Icons.paid,
        current: income.annualEstimate,
        target: 1000,
        xpReward: 250,
      ),
    ];
  }
}
