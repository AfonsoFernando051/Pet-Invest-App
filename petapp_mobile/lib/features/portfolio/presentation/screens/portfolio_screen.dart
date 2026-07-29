import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petapp_mobile/core/constants/app_colors.dart';
import 'package:petapp_mobile/core/di/dependency_injection.dart';
import 'package:petapp_mobile/core/utils/game_snack.dart';
import 'package:petapp_mobile/core/widgets/glass_card.dart';
import 'package:petapp_mobile/features/investment/presentation/screens/investment_configuration_screen.dart';
import 'package:petapp_mobile/features/pet/presentation/mascot/controllers/mascot_controller.dart';
import 'package:petapp_mobile/features/portfolio/domain/services/insight_generator.dart';
import 'package:petapp_mobile/features/portfolio/presentation/controllers/portfolio_controller.dart';
import 'package:petapp_mobile/features/portfolio/presentation/widgets/asset_allocation_card.dart';
import 'package:petapp_mobile/features/portfolio/presentation/widgets/hero_summary_section.dart';
import 'package:petapp_mobile/features/portfolio/presentation/widgets/holdings_section.dart';
import 'package:petapp_mobile/features/portfolio/presentation/widgets/insights_section.dart';
import 'package:petapp_mobile/features/portfolio/presentation/widgets/missions_achievements_section.dart';
import 'package:petapp_mobile/features/portfolio/presentation/widgets/passive_income_card.dart';
import 'package:petapp_mobile/features/portfolio/presentation/widgets/portfolio_health_card.dart';
import 'package:petapp_mobile/features/portfolio/presentation/widgets/quick_actions_fab.dart';
import 'package:petapp_mobile/features/portfolio/presentation/widgets/rpg_integration_card.dart';
import 'package:petapp_mobile/features/portfolio/presentation/widgets/shared/section_label.dart';
import 'package:petapp_mobile/features/portfolio/presentation/widgets/wealth_evolution_card.dart';

/// The redesigned Portfolio experience: real holdings/summary/allocation/
/// history from the backend, combined with client-derived health scoring,
/// insights, missions/achievements and RPG progression — all in the app's
/// existing space/glassmorphism visual identity.
class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  late final MascotController _mascotController;
  late final PortfolioController _controller;

  @override
  void initState() {
    super.initState();
    _mascotController = MascotController(repository: DI.mascotRepository);
    _controller = PortfolioController(
      repository: DI.portfolioRepository,
      achievementsRepository: DI.achievementsRepository,
      mascotController: _mascotController,
    );
    _mascotController.loadProfile();
    _controller.addListener(_onControllerChanged);
    _controller.loadAll();
  }

  void _onControllerChanged() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _mascotController.dispose();
    super.dispose();
  }

  void _openConfigure() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(_fadeRoute(const InvestmentConfigurationScreen()));
  }

  void _openAllocation() {
    Scrollable.ensureVisible(
      _allocationKey.currentContext ?? context,
      duration: const Duration(milliseconds: 400),
    );
  }

  final _allocationKey = GlobalKey();

  Route _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.04), end: Offset.zero)
              .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        ),
      ),
      transitionDuration: const Duration(milliseconds: 350),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoading && _controller.holdings.isEmpty && _controller.error == null) {
      return const _PortfolioSkeleton();
    }

    if (_controller.error != null && _controller.holdings.isEmpty) {
      return _ErrorState(error: _controller.error!, onRetry: _controller.loadAll);
    }

    final stats = _controller.stats;
    final insights = InsightGenerator.generate(
      stats,
      onOpenAllocation: _openAllocation,
      onOpenConfigure: _openConfigure,
    );

    return Stack(
      children: [
        RefreshIndicator(
          color: AppColors.neonCyan,
          backgroundColor: AppColors.spaceBlue,
          onRefresh: _controller.refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionLabel('RESUMO DO PORTFÓLIO'),
                const SizedBox(height: 10),
                HeroSummarySection(controller: _controller),
                const SizedBox(height: 20),
                WealthEvolutionCard(controller: _controller),
                const SizedBox(height: 20),
                Container(key: _allocationKey),
                AssetAllocationCard(allocation: _controller.allocation, totalValue: _controller.summary.currentValue),
                const SizedBox(height: 20),
                PortfolioHealthCard(health: _controller.health),
                const SizedBox(height: 20),
                RpgIntegrationCard(controller: _mascotController, stats: stats),
                const SizedBox(height: 20),
                HoldingsSection(holdings: _controller.holdings, totalPortfolioValue: _controller.summary.currentValue),
                const SizedBox(height: 20),
                InsightsSection(insights: insights),
                const SizedBox(height: 20),
                PassiveIncomeCard(estimate: _controller.passiveIncome),
                const SizedBox(height: 20),
                MissionsAchievementsSection(missions: _controller.missions, achievements: _controller.achievements),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        Positioned(
          right: 4,
          bottom: 8,
          child: QuickActionsFab(
            onBuy: _openConfigure,
            onSell: () => GameSnack.show(context, 'Venda de ativos em breve, Comandante.'),
            onRebalance: () {
              _openAllocation();
              GameSnack.showWithHaptic(context, 'Veja abaixo as categorias fora da meta sugerida.');
            },
            onReports: () => GameSnack.show(context, 'Relatórios detalhados em breve.'),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassCard(
        backgroundColor: AppColors.spaceDark.withValues(alpha: 0.6),
        borderColor: AppColors.negativeRed.withValues(alpha: 0.4),
        borderRadius: 24,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.satellite_alt, size: 56, color: AppColors.negativeRed),
              const SizedBox(height: 16),
              const Text(
                'Falha de Comunicação',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Não foi possível carregar seu portfólio.\n$error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.subtleText, fontSize: 13),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonViolet, foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple shimmering-glass skeleton shown while the first load is in flight.
class _PortfolioSkeleton extends StatelessWidget {
  const _PortfolioSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _bar(height: 130),
        const SizedBox(height: 20),
        _bar(height: 260),
        const SizedBox(height: 20),
        _bar(height: 200),
        const SizedBox(height: 20),
        _bar(height: 260),
      ],
    );
  }

  Widget _bar({required double height}) {
    return _Shimmer(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.spaceDark.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
    );
  }
}

class _Shimmer extends StatefulWidget {
  const _Shimmer({required this.child});

  final Widget child;

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: 0.5 + 0.5 * (0.5 + 0.5 * (1 - (2 * (_controller.value - 0.5)).abs())),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
