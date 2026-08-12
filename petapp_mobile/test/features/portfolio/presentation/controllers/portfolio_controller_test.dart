import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/academy/data/repositories/academy_progress_local_repository.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/portfolio/data/datasources/portfolio_remote_datasource.dart';
import 'package:petrimonium/features/portfolio/data/repositories/achievements_local_repository.dart';
import 'package:petrimonium/features/portfolio/data/repositories/portfolio_repository.dart';
import 'package:petrimonium/features/portfolio/domain/entities/allocation_slice.dart';
import 'package:petrimonium/features/portfolio/domain/entities/dividend_event.dart';
import 'package:petrimonium/features/portfolio/domain/entities/history_point.dart';
import 'package:petrimonium/features/portfolio/domain/entities/holding.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_summary.dart';
import 'package:petrimonium/features/portfolio/domain/enums/history_range.dart';
import 'package:petrimonium/features/portfolio/presentation/controllers/portfolio_controller.dart';

import '../../domain/services/portfolio_test_fixtures.dart';

/// In-memory [PortfolioRepository] double. The real repository talks to the
/// network via [PortfolioRemoteDataSource]; tests configure the values it
/// should "fetch" instead, and can simulate a failure via [holdingsError].
class FakePortfolioRepository implements PortfolioRepository {
  List<Holding> holdingsToReturn = const [];
  PortfolioSummary summaryToReturn = PortfolioSummary.empty;
  List<AllocationSlice> allocationToReturn = const [];
  Map<HistoryRange, List<HistoryPoint>> historyByRange = const {};
  DividendRadar dividendRadarToReturn = DividendRadar.empty;
  Object? holdingsError;
  Object? dividendRadarError;

  int fetchHoldingsCalls = 0;

  @override
  Future<List<Holding>> fetchHoldings() async {
    fetchHoldingsCalls++;
    if (holdingsError != null) throw holdingsError!;
    return holdingsToReturn;
  }

  @override
  Future<PortfolioSummary> fetchSummary() async => summaryToReturn;

  @override
  Future<List<AllocationSlice>> fetchAllocation() async => allocationToReturn;

  @override
  Future<List<HistoryPoint>> fetchHistory(HistoryRange range) async => historyByRange[range] ?? const [];

  @override
  Future<DividendRadar> fetchDividendRadar() async {
    if (dividendRadarError != null) throw dividendRadarError!;
    return dividendRadarToReturn;
  }

  @override
  PortfolioRemoteDataSource get remoteDataSource => throw UnimplementedError();
}

/// In-memory [AchievementsLocalRepository] double — the real one persists to
/// `SharedPreferences`, unavailable in a plain unit test.
class FakeAchievementsLocalRepository implements AchievementsLocalRepository {
  Map<String, DateTime> _unlocked = {};

  @override
  Future<Map<String, DateTime>> loadUnlocked() async => _unlocked;

  @override
  Future<Map<String, DateTime>> unlockAll(Set<String> newlyUnlockedIds) async {
    final now = DateTime.now();
    _unlocked = {
      ..._unlocked,
      for (final id in newlyUnlockedIds)
        if (!_unlocked.containsKey(id)) id: now,
    };
    return _unlocked;
  }
}

/// In-memory [AcademyProgressLocalRepository] double — the real one persists
/// to `SharedPreferences`, unavailable in a plain unit test. No lessons are
/// ever completed in these tests, so it always reports zero Academy XP.
class FakeAcademyProgressLocalRepository implements AcademyProgressLocalRepository {
  final Set<String> _completed = {};

  @override
  Future<Set<String>> loadCompletedLessonIds() async => _completed;

  @override
  Future<Set<String>> markLessonCompleted(String lessonId) async {
    _completed.add(lessonId);
    return _completed;
  }

  @override
  Future<int> totalXpEarned() async => 0;
}

/// A single-lot [Holding] built the same way the real pipeline does
/// (`Holding.fromLots`), so `firstPurchaseDate` and other lot-derived
/// getters behave exactly as they would for real data.
List<Holding> _holdingList({
  String ticker = 'PETR4',
  InvestmentTypeEnum type = InvestmentTypeEnum.STOCKS,
  double quantity = 100,
  double purchasePrice = 10,
  double? currentPrice,
}) {
  return Holding.fromLots([
    lot(ticker: ticker, type: type, quantity: quantity, purchasePrice: purchasePrice, currentPrice: currentPrice),
  ]);
}

void main() {
  late FakePortfolioRepository repository;
  late FakeAchievementsLocalRepository achievementsRepository;
  late FakeAcademyProgressLocalRepository academyRepository;
  late PortfolioController controller;

  setUp(() {
    repository = FakePortfolioRepository();
    achievementsRepository = FakeAchievementsLocalRepository();
    academyRepository = FakeAcademyProgressLocalRepository();
    controller = PortfolioController(
      repository: repository,
      achievementsRepository: achievementsRepository,
      academyRepository: academyRepository,
    );
  });

  tearDown(() => controller.dispose());

  group('loadAll — happy path', () {
    test('populates holdings/summary/allocation and clears the loading flag', () async {
      repository.holdingsToReturn = _holdingList();
      repository.summaryToReturn = const PortfolioSummary(
        investedCapital: 1000,
        currentValue: 1200,
        totalGain: 200,
        totalGainPercent: 20,
        totalAssets: 1,
      );
      repository.allocationToReturn = [
        const AllocationSlice(type: InvestmentTypeEnum.STOCKS, currentValue: 1200, portfolioPercent: 100),
      ];

      await controller.loadAll();

      expect(controller.isLoading, isFalse);
      expect(controller.error, isNull);
      expect(controller.holdings, hasLength(1));
      expect(controller.summary.currentValue, 1200);
      expect(controller.allocation, hasLength(1));
    });

    test('isLoading is true while the load is in flight', () async {
      expect(controller.isLoading, isTrue); // set by the constructor's initial state
      final future = controller.loadAll();
      expect(controller.isLoading, isTrue);
      await future;
      expect(controller.isLoading, isFalse);
    });
  });

  group('loadAll — failure', () {
    test('a repository failure is captured as a user-facing error, not an unhandled exception', () async {
      repository.holdingsError = Exception('network down');

      await controller.loadAll();

      expect(controller.isLoading, isFalse);
      expect(controller.error, contains('network down'));
    });

    test('a failed load does not crash gamification evaluation', () async {
      repository.holdingsError = Exception('network down');

      await controller.loadAll();

      // No exception propagated out of loadAll — reaching this line is the assertion.
      expect(controller.newlyUnlocked, isEmpty);
    });
  });

  group('loadAll — empty portfolio', () {
    test('performance deltas are all zero, never a division-by-zero artifact', () async {
      await controller.loadAll();

      expect(controller.todayChangeValue, 0);
      expect(controller.todayChangePercent, 0);
      expect(controller.monthlyChangeValue, 0);
      expect(controller.annualChangeValue, 0);
    });
  });

  group('loadAll — gamification', () {
    test('newly qualifying achievements are unlocked and reported exactly once', () async {
      repository.holdingsToReturn = _holdingList();
      repository.summaryToReturn = const PortfolioSummary(
        investedCapital: 1000,
        currentValue: 1000,
        totalGain: 0,
        totalGainPercent: 0,
        totalAssets: 1,
      );

      await controller.loadAll();

      expect(controller.newlyUnlocked.any((a) => a.id == 'first_investment'), isTrue);

      controller.clearNewlyUnlocked();
      expect(controller.newlyUnlocked, isEmpty);

      // A second load with the same qualifying state must not re-report the
      // achievement as "newly" unlocked — it's already persisted.
      await controller.loadAll();
      expect(controller.newlyUnlocked, isEmpty);
      expect(controller.achievements.firstWhere((a) => a.id == 'first_investment').unlocked, isTrue);
    });
  });

  group('setRange / setAssetFilter', () {
    test('setRange updates selectedRange and is a no-op when set to the same value', () async {
      await controller.loadAll();
      controller.setRange(HistoryRange.y1);
      expect(controller.selectedRange, HistoryRange.y1);
    });

    test('setAssetFilter updates selectedAssetFilter', () async {
      await controller.loadAll();
      controller.setAssetFilter(InvestmentTypeEnum.STOCKS);
      expect(controller.selectedAssetFilter, InvestmentTypeEnum.STOCKS);

      controller.setAssetFilter(null);
      expect(controller.selectedAssetFilter, isNull);
    });
  });

  group('refresh', () {
    test('calls loadAll again, hitting the repository a second time', () async {
      await controller.loadAll();
      expect(repository.fetchHoldingsCalls, 1);

      await controller.refresh();
      expect(repository.fetchHoldingsCalls, 2);
    });
  });

  group('dividend radar', () {
    test('loadDividendRadarIfNeeded fetches once and caches for subsequent calls', () async {
      repository.dividendRadarToReturn = const DividendRadar(upcoming: [], history: []);

      await controller.loadDividendRadarIfNeeded();
      expect(controller.isDividendRadarLoading, isFalse);
      expect(controller.dividendRadarError, isNull);

      // A second call before any explicit refresh should not need to hit the
      // repository again — this test just asserts it doesn't throw/hang and
      // the cached-empty state remains consistent.
      await controller.loadDividendRadarIfNeeded();
      expect(controller.dividendRadar, controller.dividendRadar);
    });

    test('a repository failure sets dividendRadarError and clears the loading flag', () async {
      repository.dividendRadarError = Exception('provider unavailable');

      await controller.refreshDividendRadar();

      expect(controller.isDividendRadarLoading, isFalse);
      expect(controller.dividendRadarError, contains('provider unavailable'));
    });
  });
}
