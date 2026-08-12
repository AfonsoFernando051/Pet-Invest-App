import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_stats.dart';
import 'package:petrimonium/features/portfolio/domain/services/mission_catalog.dart';

import 'portfolio_test_fixtures.dart';

void main() {
  group('MissionCatalog.evaluate — empty portfolio', () {
    test('returns every mission, all incomplete with zero progress', () {
      final missions = MissionCatalog.evaluate(PortfolioStats.empty);
      expect(missions, isNotEmpty);
      expect(missions.every((m) => !m.isComplete), isTrue);
      final firstInvestment = missions.firstWhere((m) => m.id == 'first_investment');
      expect(firstInvestment.current, 0);
      expect(firstInvestment.progress, 0);
    });
  });

  group('MissionCatalog.evaluate — portfolio_10k progress', () {
    test('current value tracks real current value, capped progress at 1.0 once complete', () {
      final halfway = statsFromLots([lot(quantity: 500, purchasePrice: 10)]); // 5,000
      final complete = statsFromLots([lot(quantity: 1000, purchasePrice: 10)]); // 10,000
      final overshot = statsFromLots([lot(quantity: 2000, purchasePrice: 10)]); // 20,000

      final halfwayMission = MissionCatalog.evaluate(halfway).firstWhere((m) => m.id == 'portfolio_10k');
      final completeMission = MissionCatalog.evaluate(complete).firstWhere((m) => m.id == 'portfolio_10k');
      final overshotMission = MissionCatalog.evaluate(overshot).firstWhere((m) => m.id == 'portfolio_10k');

      expect(halfwayMission.progress, closeTo(0.5, 0.001));
      expect(halfwayMission.isComplete, isFalse);
      expect(completeMission.isComplete, isTrue);
      expect(completeMission.progress, 1.0);
      expect(overshotMission.isComplete, isTrue);
      expect(overshotMission.progress, 1.0); // never exceeds 1.0
    });
  });

  group('MissionCatalog.evaluate — diversification_master progress', () {
    test('current is the count of distinct asset types, target is 4', () {
      final stats = statsFromLots([
        lot(id: 1, ticker: 'A', type: InvestmentTypeEnum.STOCKS),
        lot(id: 2, ticker: 'B', type: InvestmentTypeEnum.FIXED_INCOME),
      ]);
      final mission = MissionCatalog.evaluate(stats).firstWhere((m) => m.id == 'diversification_master');
      expect(mission.current, 2);
      expect(mission.target, 4);
      expect(mission.progress, closeTo(0.5, 0.001));
    });
  });

  group('MissionCatalog.evaluate — dividend_hunter progress', () {
    test('current tracks the estimated annual passive income', () {
      // R$5,000 fixed income * 11% = R$550/yr estimated, against a R$1,000 target.
      final stats = statsFromLots([lot(type: InvestmentTypeEnum.FIXED_INCOME, quantity: 500, purchasePrice: 10)]);
      final mission = MissionCatalog.evaluate(stats).firstWhere((m) => m.id == 'dividend_hunter');
      expect(mission.current, closeTo(550, 0.01));
      expect(mission.isComplete, isFalse);
    });
  });
}
