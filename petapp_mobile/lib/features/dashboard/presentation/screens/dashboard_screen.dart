import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_tokens.dart';
import '../../../../core/utils/translator.dart';
import '../../../../core/utils/game_snack.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/confirm_logout_dialog.dart';
import '../../../../core/theme/background_presets.dart';
import '../../../../core/widgets/cosmic_background.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/events/app_event.dart';
import '../../../../core/events/app_event_bus.dart';
import '../../../academy/presentation/screens/academy_home_screen.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../game/domain/services/level_calculator.dart';
import '../../../pet/presentation/mascot/controllers/mascot_controller.dart';
import '../../../portfolio/domain/entities/achievement.dart';
import '../../../portfolio/presentation/controllers/portfolio_controller.dart';
import '../../../portfolio/presentation/screens/passive_income_screen.dart';
import '../../../portfolio/presentation/screens/portfolio_screen.dart';
import '../../../portfolio/presentation/widgets/achievement_celebration_overlay.dart';
import '../../../portfolio/presentation/widgets/asset_allocation_card.dart';
import '../../../portfolio/presentation/widgets/dividend_notifications_sheet.dart';
import '../../../portfolio/presentation/widgets/hero_summary_section.dart';
import '../../../portfolio/presentation/widgets/missions_achievements_section.dart';
import '../../../portfolio/presentation/widgets/shared/error_banner.dart';
import '../../../portfolio/presentation/widgets/wealth_evolution_card.dart';
import '../../../mentor/presentation/screens/mentor_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../widgets/pet_showcase.dart';
import '../widgets/action_buttons.dart';
import '../widgets/portfolio_not_connected_card.dart';
import '../widgets/portfolio_reminder_banner.dart';
import '../widgets/suggested_actions_list.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // Shared across the Início (Home) and Carteira (Portfolio) tabs so both
  // reflect the same real holdings/summary/allocation data and a single
  // in-flight load — no duplicate fetches, no drift between tabs.
  late final MascotController _mascotController;
  late final PortfolioController _portfolioController;

  // Newly-unlocked achievements awaiting their celebration overlay (see
  // `PortfolioController.newlyUnlocked`) — previously these unlocked
  // completely silently, with no on-screen reward moment at all.
  List<Achievement> _celebrating = [];

  // Whether the pet should nudge the user about the (skipped) portfolio
  // step this session, and whether the risk-assessment questionnaire is
  // still unanswered — both feed the "what to do now" placeholder content
  // shown when there's no live portfolio yet.
  bool _showPortfolioReminder = false;
  bool _investorProfileUnanswered = false;

  // First real consumer of `AppEventBus`: reacts to game-progression events
  // (currently just level-ups) without the emitter (`MascotController`)
  // knowing this screen exists.
  StreamSubscription<AppEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _mascotController = MascotController(repository: DI.mascotRepository);
    _portfolioController = PortfolioController(
      repository: DI.portfolioRepository,
      achievementsRepository: DI.achievementsRepository,
      mascotController: _mascotController,
    );
    _mascotController.loadProfile();
    _portfolioController.addListener(_onPortfolioChanged);
    _portfolioController.loadAll();
    // Loaded here (not just on first Proventos-tab visit) so the
    // notification bell's badge reflects real upcoming payments as soon as
    // the dashboard opens, even if the user never taps into Proventos.
    _portfolioController.loadDividendRadarIfNeeded();
    _loadOnboardingSignals();
    _eventSubscription = AppEventBus.instance.stream.listen(_onAppEvent);
  }

  void _onAppEvent(AppEvent event) {
    if (!mounted) return;
    if (event is UserLeveledUpEvent) {
      GameSnack.showWithHaptic(
        context,
        Translator.translate(AppStrings.levelUpAchieved, params: {'level': '${event.newLevel}'}),
        isSuccess: true,
      );
    }
  }

  Future<void> _loadOnboardingSignals() async {
    final showReminder = await DI.onboardingStateRepository.shouldShowPortfolioReminder();
    if (showReminder) {
      // Recorded the moment we decide to show it, not on dismiss — so a
      // user who just navigates away without tapping anything still gets
      // the cooldown, instead of seeing it again next session.
      final sessionCount = await DI.onboardingStateRepository.currentSessionCount();
      await DI.onboardingStateRepository.markReminderShown(sessionCount);
    }

    bool investorProfileUnanswered = false;
    try {
      final status = await DI.onboardingRepository.getStatus();
      investorProfileUnanswered = !status.hasAnswered;
    } catch (_) {
      // Non-critical suggestion — if the status check fails, just omit it.
    }
    if (!mounted) return;
    setState(() {
      _showPortfolioReminder = showReminder;
      _investorProfileUnanswered = investorProfileUnanswered;
    });
  }

  void _onPortfolioChanged() {
    setState(() {
      if (_portfolioController.newlyUnlocked.isNotEmpty) {
        _celebrating = _portfolioController.newlyUnlocked;
        _portfolioController.clearNewlyUnlocked();
      }
    });
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _portfolioController.removeListener(_onPortfolioChanged);
    _portfolioController.dispose();
    _mascotController.dispose();
    super.dispose();
  }

  // Shared background instance for all tabs (the IndexedStack below keeps
  // every tab's state alive, so there's one CosmicBackground behind all of
  // them, not five). Content-hierarchy comes from swapping `intensity` per
  // selected tab instead: full cosmic expression on Home, progressively
  // quieter as the screen gets more cognitively demanding, down to Academy.
  // Lesson/quiz screens go one step further with their own `focus`-level
  // CosmicBackground pushed as a separate route (see LessonScreen).
  static const List<BackgroundIntensity> _tabIntensities = [
    BackgroundIntensity.immersive, // Home
    BackgroundIntensity.balanced, // Carteira / Portfolio
    BackgroundIntensity.balanced, // Proventos / Passive income
    BackgroundIntensity.subtle, // Academia
    BackgroundIntensity.mentor, // Mentor
  ];

  Widget _buildBackground({required Widget child}) {
    return CosmicBackground(intensity: _tabIntensities[_selectedIndex], child: child);
  }

  // ── Page route helper ─────────────────────────────────────────────────────
  Route _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        ),
      ),
      transitionDuration: const Duration(milliseconds: 350),
    );
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> _confirmLogout() async {
    final confirmed = await ConfirmLogoutDialog.show(context);

    if (confirmed && mounted) {
      HapticFeedback.mediumImpact();
      await DI.authRepository.logout();
      if (mounted) {
        Navigator.of(context).pushReplacement(_fadeRoute(const LoginScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Rebuilds the AppBar/bottom-nav chrome (and everything under it) when
    // the user switches language in Settings — matches the same explicit
    // per-screen listening pattern `SettingsScreen` and the Academy screens
    // already use, rather than relying on the top-level `MyApp` rebuild
    // alone (which resets `FutureBuilder`'s start-route resolution and would
    // otherwise flash the splash screen on every language switch).
    return ValueListenableBuilder<String>(
      valueListenable: Translator.languageNotifier,
      builder: (context, _, __) => _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final tokens = context.colors;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: _buildAppBarTitle(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: tokens.textSecondary),
            onPressed: () {},
          ),
          _buildNotificationsButton(),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: tokens.textSecondary),
            tooltip: Translator.translate(AppStrings.profileTooltip),
            onPressed: () async {
              await Navigator.of(context).push(_fadeRoute(const ProfileScreen()));
              // Settings (reached via Profile) may have renamed the pet —
              // reload so the AppBar/greeting reflect it immediately.
              await _mascotController.loadProfile();
              if (mounted) setState(() {});
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.neonPurple),
            tooltip: Translator.translate(AppStrings.logoutTooltip),
            onPressed: _confirmLogout,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          _buildBackground(
            child: SafeArea(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  _buildHomeContent(),
                  _buildWalletContent(),
                  _buildPassiveIncomeContent(),
                  _buildAcademyContent(),
                  _buildMentorContent(),
                ],
              ),
            ),
          ),
          if (_celebrating.isNotEmpty)
            AchievementCelebrationOverlay(
              achievements: _celebrating,
              onDismiss: () => setState(() => _celebrating = []),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── AppBar title — compact player HUD ────────────────────────────────────
  Widget _buildAppBarTitle() {
    // Real level derived from the same accumulated XP that drives pet
    // evolution (`MascotController.profile.xp`), not a hardcoded number.
    final level = LevelCalculator.fromXp(_mascotController.profile.xp).level;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.7), width: 1.5),
            color: context.colors.surface.withValues(alpha: context.isDarkMode ? 0.6 : 0.9),
          ),
          child: const Icon(Icons.person_outline, size: 18, color: AppColors.neonCyan),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Invest Game',
              style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              _mascotController.profile.name?.isNotEmpty == true
                  ? Translator.translate(
                      AppStrings.appBarPlayerNamedGreeting,
                      params: {'petName': _mascotController.profile.name!, 'level': '$level'},
                    )
                  : Translator.translate(AppStrings.appBarPlayerGenericGreeting, params: {'level': '$level'}),
              style: TextStyle(color: context.colors.primary.withValues(alpha: 0.9), fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }

  // ── Notifications: upcoming dividends for the user's real holdings ──────
  // Badge count is real and provider-confirmed (`DividendRadar.upcoming`,
  // the same data `DividendRadarSection` renders on the Proventos tab) —
  // never a placeholder or simulated count.
  Widget _buildNotificationsButton() {
    final upcomingCount = _portfolioController.dividendRadar.upcoming.length;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(Icons.notifications_outlined, color: context.colors.textSecondary),
          tooltip: Translator.translate(AppStrings.notificationsTooltip),
          onPressed: _openNotifications,
        ),
        if (upcomingCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                decoration: BoxDecoration(
                  color: context.colors.error,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.colors.backgroundSecondary, width: 1.5),
                ),
                child: Text(
                  upcomingCount > 9 ? '9+' : '$upcomingCount',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _openNotifications() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AnimatedBuilder(
        animation: _portfolioController,
        builder: (context, _) => DividendNotificationsSheet(
          isLoading: _portfolioController.isDividendRadarLoading,
          error: _portfolioController.dividendRadarError,
          upcoming: _portfolioController.dividendRadar.upcoming,
          onRetry: _portfolioController.refreshDividendRadar,
        ),
      ),
    );
  }

  // ── Home: the app's executive dashboard ──────────────────────────────────
  // Charts, allocation, insights, passive income and gamification all live
  // here now — Carteira (Portfolio) is holdings-management only. Both tabs
  // share `_portfolioController`/`_mascotController` so they always agree.
  Widget _buildHomeContent() {
    if (_portfolioController.isLoading &&
        _portfolioController.holdings.isEmpty &&
        _portfolioController.error == null) {
      return const AppLoadingIndicator();
    }

    // No real holdings yet — whether the user skipped portfolio setup or
    // just hasn't gotten to it, Home must stay fully usable: placeholders
    // and "what to do now" suggestions stand in for the data-driven cards.
    final hasPortfolio = _portfolioController.holdings.isNotEmpty;

    return RefreshIndicator(
      color: context.colors.primary,
      backgroundColor: context.colors.surfaceElevated,
      onRefresh: _portfolioController.refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_portfolioController.error != null) ...[
              ErrorBanner(onRetry: _portfolioController.refresh),
              const SizedBox(height: 12),
            ],
            PetShowcase(performancePercent: _portfolioController.summary.totalGainPercent),
            const SizedBox(height: 16),

            if (_showPortfolioReminder) ...[
              PortfolioReminderBanner(onDismiss: () => setState(() => _showPortfolioReminder = false)),
              const SizedBox(height: 16),
            ],

            if (!hasPortfolio) ...[
              const PortfolioNotConnectedCard(),
              const SizedBox(height: 16),
              _buildSectionLabel(Translator.translate(AppStrings.suggestedActionsTitle).toUpperCase()),
              const SizedBox(height: 8),
              SuggestedActionsList(
                onLearnDividends: () => setState(() => _selectedIndex = 2),
                onOpenAcademy: () => setState(() => _selectedIndex = 3),
                showInvestorProfileAction: _investorProfileUnanswered,
              ),
              const SizedBox(height: 16),
            ] else ...[
              _buildSectionLabel('RESUMO DO PORTFÓLIO'),
              const SizedBox(height: 8),
              HeroSummarySection(controller: _portfolioController),
              const SizedBox(height: 16),

              WealthEvolutionCard(controller: _portfolioController),
              const SizedBox(height: 16),

              AssetAllocationCard(
                allocation: _portfolioController.allocation,
                totalValue: _portfolioController.summary.currentValue,
              ),
              const SizedBox(height: 16),
            ],

            _buildSectionLabel('AÇÕES RÁPIDAS'),
            const SizedBox(height: 8),
            ActionButtons(onTrainTap: () => setState(() => _selectedIndex = 3)),
            const SizedBox(height: 16),

            MissionsAchievementsSection(
              missions: _portfolioController.missions,
              achievements: _portfolioController.achievements,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        color: context.colors.primary.withValues(alpha: 0.6),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.0,
      ),
    );
  }

  // ── Wallet / Portfolio ───────────────────────────────────────────────────
  Widget _buildWalletContent() {
    return PortfolioScreen(controller: _portfolioController);
  }

  // ── Proventos / Passive Income ────────────────────────────────────────────
  Widget _buildPassiveIncomeContent() {
    return PassiveIncomeScreen(controller: _portfolioController);
  }

  // ── Academia: module/lesson progression (see docs/ACADEMY_ENGINE.md) ────
  Widget _buildAcademyContent() {
    return AcademyHomeScreen(mascotController: _mascotController);
  }

  // ── Mentor: AI-powered chat with the pet acting as investment mentor ────
  Widget _buildMentorContent() {
    return const MentorScreen();
  }

  // ── Analytics (hidden from navigation for now — kept for a future tab) ───
  // ignore: unused_element
  Widget _buildAnalyticsContent() {
    final tokens = context.colors;
    return Center(
      child: GlassCard(
        backgroundColor: tokens.surface.withValues(alpha: context.isDarkMode ? 0.6 : 0.94),
        borderColor: AppColors.neonCyan.withValues(alpha: 0.3),
        borderRadius: 24,
        borderWidth: 1,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_graph, size: 64, color: AppColors.neonCyan.withValues(alpha: 0.6)),
              const SizedBox(height: 16),
              Text(
                'Análise Estratégica',
                style: TextStyle(color: tokens.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Centro de análise de ativos\nem construção, Comandante.',
                textAlign: TextAlign.center,
                style: TextStyle(color: tokens.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Bottom Nav ────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final tokens = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: tokens.backgroundSecondary,
        border: Border(top: BorderSide(color: tokens.primary.withValues(alpha: 0.3), width: 1)),
        boxShadow: [
          BoxShadow(
            color: tokens.primary.withValues(alpha: context.isDarkMode ? 0.12 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: tokens.primary,
        unselectedItemColor: tokens.textTertiary,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        currentIndex: _selectedIndex,
        onTap: (i) {
          HapticFeedback.selectionClick();
          setState(() => _selectedIndex = i);
        },
        items: [
          BottomNavigationBarItem(
            icon: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(Icons.rocket_launch_outlined),
            ),
            activeIcon: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(Icons.rocket_launch),
            ),
            label: Translator.translate(AppStrings.navHome),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.diamond_outlined),
            activeIcon: const Icon(Icons.diamond),
            label: Translator.translate(AppStrings.navWallet),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.payments_outlined),
            activeIcon: const Icon(Icons.payments),
            label: Translator.translate(AppStrings.navPassiveIncome),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.school_outlined),
            activeIcon: const Icon(Icons.school),
            label: Translator.translate(AppStrings.navAcademy),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.auto_awesome_outlined),
            activeIcon: const Icon(Icons.auto_awesome),
            label: Translator.translate(AppStrings.navMentor),
          ),
        ],
      ),
    );
  }
}
