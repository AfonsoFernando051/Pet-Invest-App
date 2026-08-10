import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/translator.dart';
import '../../../../core/utils/game_snack.dart';
import '../../../../core/widgets/cosmic_background.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/events/app_event.dart';
import '../../../../core/events/app_event_bus.dart';
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
        'Nível ${event.newLevel} alcançado!',
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

  // Shared background for all tabs — slow drift + twinkling stars so the
  // space theme reads as alive rather than a static wallpaper.
  Widget _buildBackground({required Widget child}) {
    return CosmicBackground(child: child);
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.spaceBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Sair do Invest Game?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Tem certeza que deseja encerrar sua sessão?',
          style: TextStyle(color: AppColors.subtleText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.neonCyan)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair', style: TextStyle(color: AppColors.negativeRed)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      HapticFeedback.mediumImpact();
      await DI.authRepository.logout();
      if (mounted) {
        Navigator.of(context).pushReplacement(_fadeRoute(const LoginScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: _buildAppBarTitle(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white70),
            onPressed: () {},
          ),
          _buildNotificationsButton(),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white70),
            tooltip: 'Perfil',
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
            tooltip: 'Sair',
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
            color: AppColors.spaceDark.withValues(alpha: 0.6),
          ),
          child: const Icon(Icons.person_outline, size: 18, color: AppColors.neonCyan),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Invest Game',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              _mascotController.profile.name?.isNotEmpty == true
                  ? '${_mascotController.profile.name} · Nível $level'
                  : 'Nível $level · Explorador',
              style: TextStyle(color: AppColors.neonCyan.withValues(alpha: 0.9), fontSize: 11),
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
          icon: const Icon(Icons.notifications_outlined, color: Colors.white70),
          tooltip: 'Notificações',
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
                  color: AppColors.negativeRed,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.backgroundDark, width: 1.5),
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
      return const Center(child: CircularProgressIndicator(color: AppColors.neonCyan));
    }

    // No real holdings yet — whether the user skipped portfolio setup or
    // just hasn't gotten to it, Home must stay fully usable: placeholders
    // and "what to do now" suggestions stand in for the data-driven cards.
    final hasPortfolio = _portfolioController.holdings.isNotEmpty;

    return RefreshIndicator(
      color: AppColors.neonCyan,
      backgroundColor: AppColors.spaceBlue,
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
            const ActionButtons(),
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
        color: AppColors.neonCyan.withValues(alpha: 0.5),
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

  // ── Mentor: AI-powered chat with the pet acting as investment mentor ────
  Widget _buildMentorContent() {
    return const MentorScreen();
  }

  // ── Analytics (hidden from navigation for now — kept for a future tab) ───
  // ignore: unused_element
  Widget _buildAnalyticsContent() {
    return Center(
      child: GlassCard(
        backgroundColor: AppColors.spaceDark.withValues(alpha: 0.6),
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
              const Text(
                'Análise Estratégica',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Centro de análise de ativos\nem construção, Comandante.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.subtleText, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Bottom Nav ────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border(top: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.3), width: 1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonCyan.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.neonCyan,
        unselectedItemColor: Colors.white38,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        currentIndex: _selectedIndex,
        onTap: (i) {
          HapticFeedback.selectionClick();
          setState(() => _selectedIndex = i);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(Icons.rocket_launch_outlined),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(Icons.rocket_launch),
            ),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.diamond_outlined),
            activeIcon: Icon(Icons.diamond),
            label: 'Carteira',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payments_outlined),
            activeIcon: Icon(Icons.payments),
            label: 'Proventos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_outlined),
            activeIcon: Icon(Icons.auto_awesome),
            label: 'Mentor',
          ),
        ],
      ),
    );
  }
}
