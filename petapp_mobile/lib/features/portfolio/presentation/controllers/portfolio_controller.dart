import 'package:flutter/foundation.dart';
import 'package:petrimonium/core/events/app_event.dart';
import 'package:petrimonium/core/events/app_event_bus.dart';
import 'package:petrimonium/core/services/total_xp_calculator.dart';
import 'package:petrimonium/features/academy/data/repositories/academy_progress_local_repository.dart';
import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';
import 'package:petrimonium/features/portfolio/data/repositories/achievements_local_repository.dart';
import 'package:petrimonium/features/portfolio/data/repositories/portfolio_repository.dart';
import 'package:petrimonium/features/portfolio/domain/entities/achievement.dart';
import 'package:petrimonium/features/portfolio/domain/entities/allocation_slice.dart';
import 'package:petrimonium/features/portfolio/domain/entities/dividend_event.dart';
import 'package:petrimonium/features/portfolio/domain/entities/history_point.dart';
import 'package:petrimonium/features/portfolio/domain/entities/holding.dart';
import 'package:petrimonium/features/portfolio/domain/entities/investment_lot.dart';
import 'package:petrimonium/features/portfolio/domain/entities/mission.dart';
import 'package:petrimonium/features/portfolio/domain/entities/passive_income_estimate.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_health.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_stats.dart';
import 'package:petrimonium/features/portfolio/domain/entities/portfolio_summary.dart';
import 'package:petrimonium/features/portfolio/domain/enums/history_range.dart';
import 'package:petrimonium/features/portfolio/domain/services/achievement_catalog.dart';
import 'package:petrimonium/features/portfolio/domain/services/mission_catalog.dart';
import 'package:petrimonium/features/portfolio/domain/services/passive_income_estimator.dart';
import 'package:petrimonium/features/portfolio/domain/services/portfolio_health_calculator.dart';
import 'package:petrimonium/features/portfolio/domain/services/wealth_history_calculator.dart';

/// Owns all state for the redesigned Portfolio screen: real holdings/
/// summary/allocation/history from the backend, plus everything derived
/// client-side from that real data (health score, insights, missions,
/// achievements, estimated passive income). When [mascotController] is
/// supplied, every successful load feeds the user's real net worth and
/// achievement-earned XP into `MascotController.evaluateEvolution` — the
/// first real wiring between actual portfolio data and pet progression.
class PortfolioController extends ChangeNotifier {
  PortfolioController({
    required PortfolioRepository repository,
    required AchievementsLocalRepository achievementsRepository,
    AcademyProgressLocalRepository? academyRepository,
    MascotController? mascotController,
    AppEventBus? eventBus,
  })  : _repository = repository,
        _achievementsRepository = achievementsRepository,
        _academyRepository = academyRepository ?? AcademyProgressLocalRepository(),
        _mascotController = mascotController,
        _eventBus = eventBus ?? AppEventBus.instance;

  final PortfolioRepository _repository;
  final AchievementsLocalRepository _achievementsRepository;
  final AcademyProgressLocalRepository _academyRepository;
  final MascotController? _mascotController;
  final AppEventBus _eventBus;

  bool isLoading = true;
  String? error;

  List<Holding> holdings = [];
  PortfolioSummary summary = PortfolioSummary.empty;
  List<AllocationSlice> allocation = [];
  Map<String, DateTime> _unlockedAchievements = {};

  /// Achievements that became unlocked on the *most recent* `loadAll()` call
  /// — i.e. genuinely new this session, not just "unlocked at some point in
  /// the past" (see `_evaluateGamification`, which diffs against what was
  /// already persisted before recomputing). The UI shows a celebration for
  /// these, then calls [clearNewlyUnlocked].
  List<Achievement> newlyUnlocked = [];

  void clearNewlyUnlocked() {
    newlyUnlocked = [];
  }

  HistoryRange selectedRange = HistoryRange.m3;
  InvestmentTypeEnum? selectedAssetFilter;
  List<HistoryPoint> chartPoints = [];

  double todayChangeValue = 0;
  double todayChangePercent = 0;
  double monthlyChangeValue = 0;
  double monthlyChangePercent = 0;
  double annualChangeValue = 0;
  double annualChangePercent = 0;

  final Map<HistoryRange, List<HistoryPoint>> _backendHistoryCache = {};

  // Real, provider-confirmed dividend/JCP/yield history for the user's real
  // holdings (contrast with `passiveIncome` below, which is an *estimate*).
  // Loaded lazily — only the Proventos tab needs it, and each ticker is a
  // real external API round-trip server-side, so Home/Carteira shouldn't pay
  // for it on every load.
  bool isDividendRadarLoading = false;
  String? dividendRadarError;
  DividendRadar dividendRadar = DividendRadar.empty;
  bool _dividendRadarLoaded = false;

  PortfolioStats get stats => PortfolioStats(summary: summary, holdings: holdings, allocation: allocation);

  PortfolioHealth get health => PortfolioHealthCalculator.calculate(stats);

  List<Mission> get missions => MissionCatalog.evaluate(stats);

  List<Achievement> get achievements => AchievementCatalog.resolve(_unlockedAchievements);

  PassiveIncomeEstimate get passiveIncome => PassiveIncomeEstimator.estimate(stats);

  List<InvestmentLot> get _allLots => holdings.expand((h) => h.lots).toList();

  Future<void> loadAll() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.fetchHoldings(),
        _repository.fetchAllocation(),
        _repository.fetchSummary(),
      ]);
      holdings = results[0] as List<Holding>;
      allocation = results[1] as List<AllocationSlice>;
      summary = results[2] as PortfolioSummary;

      await _loadPerformanceDeltas();
      _recomputeChart();
      await _evaluateGamification();
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => loadAll();

  /// Fetches the real dividend radar on first use and caches it for the rest
  /// of the session; call again via [refreshDividendRadar] to force a reload
  /// (e.g. pull-to-refresh on the Proventos tab).
  Future<void> loadDividendRadarIfNeeded() async {
    if (_dividendRadarLoaded || isDividendRadarLoading) return;
    await _fetchDividendRadar();
  }

  Future<void> refreshDividendRadar() => _fetchDividendRadar();

  Future<void> _fetchDividendRadar() async {
    isDividendRadarLoading = true;
    dividendRadarError = null;
    notifyListeners();

    try {
      dividendRadar = await _repository.fetchDividendRadar();
      _dividendRadarLoaded = true;
    } catch (e) {
      dividendRadarError = e.toString();
    }

    isDividendRadarLoading = false;
    notifyListeners();
  }

  void setRange(HistoryRange range) {
    if (range == selectedRange) return;
    selectedRange = range;
    _recomputeChart();
    notifyListeners();
  }

  void setAssetFilter(InvestmentTypeEnum? type) {
    if (type == selectedAssetFilter) return;
    selectedAssetFilter = type;
    _recomputeChart();
    notifyListeners();
  }

  Future<void> _loadPerformanceDeltas() async {
    if (holdings.isEmpty) {
      todayChangeValue = 0;
      todayChangePercent = 0;
      monthlyChangeValue = 0;
      monthlyChangePercent = 0;
      annualChangeValue = 0;
      annualChangePercent = 0;
      return;
    }

    final thirtyDay = await _cachedBackendHistory(HistoryRange.d30);
    final oneYear = await _cachedBackendHistory(HistoryRange.y1);

    final today = _delta(thirtyDay, fromEnd: true);
    todayChangeValue = today.$1;
    todayChangePercent = today.$2;

    final monthly = _delta(thirtyDay, fromEnd: false);
    monthlyChangeValue = monthly.$1;
    monthlyChangePercent = monthly.$2;

    final annual = _delta(oneYear, fromEnd: false);
    annualChangeValue = annual.$1;
    annualChangePercent = annual.$2;
  }

  /// [fromEnd] compares the last two samples (≈ "today"); otherwise compares
  /// the first and last sample of the series (≈ full-range change).
  (double, double) _delta(List<HistoryPoint> series, {required bool fromEnd}) {
    if (series.length < 2) return (0, 0);
    final from = fromEnd ? series[series.length - 2] : series.first;
    final to = series.last;
    final value = to.portfolioValue - from.portfolioValue;
    final percent = from.portfolioValue == 0 ? 0.0 : (value / from.portfolioValue) * 100;
    return (value, percent);
  }

  Future<List<HistoryPoint>> _cachedBackendHistory(HistoryRange range) async {
    final cached = _backendHistoryCache[range];
    if (cached != null) return cached;
    final points = await _repository.fetchHistory(range);
    _backendHistoryCache[range] = points;
    return points;
  }

  void _recomputeChart() {
    if (selectedAssetFilter != null) {
      final filteredLots = _allLots.where((l) => l.type == selectedAssetFilter).toList();
      chartPoints = WealthHistoryCalculator.compute(filteredLots, selectedRange);
      return;
    }

    final cached = _backendHistoryCache[selectedRange];
    if (cached != null) {
      chartPoints = cached;
      return;
    }

    // Not yet fetched from the backend for this range — compute locally from
    // already-loaded lots so the UI responds instantly, then fetch+replace.
    chartPoints = WealthHistoryCalculator.compute(_allLots, selectedRange);
    _repository.fetchHistory(selectedRange).then((points) {
      _backendHistoryCache[selectedRange] = points;
      if (selectedAssetFilter == null) {
        chartPoints = points;
        notifyListeners();
      }
    }).catchError((_) {
      // Keep the locally-computed series if the backend call fails.
    });
  }

  Future<void> _evaluateGamification() async {
    final currentStats = stats;
    final alreadyUnlocked = await _achievementsRepository.loadUnlocked();
    final qualifiedNow = AchievementCatalog.qualifiedIds(currentStats);
    final newIds = qualifiedNow.difference(alreadyUnlocked.keys.toSet());

    _unlockedAchievements = await _achievementsRepository.unlockAll(qualifiedNow);
    if (newIds.isNotEmpty) {
      newlyUnlocked = AchievementCatalog.resolve(_unlockedAchievements)
          .where((a) => newIds.contains(a.id))
          .toList();
      // The in-screen celebration overlay (`newlyUnlocked` above) already
      // shows these; the bus emission is for other, decoupled listeners
      // (e.g. a future Character Engine reaction) rather than a second UI.
      for (final achievement in newlyUnlocked) {
        _eventBus.emit(AchievementUnlockedEvent(achievement));
      }
    }

    // Sums achievement XP *and* Academy lesson XP (see `TotalXpCalculator`)
    // so a portfolio refresh never overwrites XP earned from a lesson —
    // `evaluateEvolution` sets the pet's stored XP outright, it doesn't add.
    final totalXp = await TotalXpCalculator.compute(
      achievementsRepository: _achievementsRepository,
      academyRepository: _academyRepository,
    );
    await _mascotController?.evaluateEvolution(summary.currentValue, totalXp);
  }
}
