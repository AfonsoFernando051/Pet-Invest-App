import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/game_snack.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/investment/presentation/screens/investment_configuration_screen.dart';
import 'package:petrimonium/features/portfolio/presentation/controllers/portfolio_controller.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/asset_allocation_card.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/hero_summary_section.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/holdings_section.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/quick_actions_fab.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/wealth_evolution_bar_card.dart';

/// The "Carteira" (Portfolio) tab — holdings (Investidor10-inspired: grouped
/// by category, collapsible, expandable to full asset detail) preceded by
/// the portfolio summary cards, wealth evolution chart and asset allocation
/// donut, so the full picture is visible before scrolling into individual
/// positions.
///
/// [controller] is owned and loaded by `DashboardScreen` and shared with the
/// Home tab, so both reflect the same data with a single fetch.
class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key, required this.controller});

  final PortfolioController controller;

  void _openConfigure(BuildContext context) {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(_fadeRoute(const InvestmentConfigurationScreen()));
  }

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
    if (controller.isLoading && controller.holdings.isEmpty && controller.error == null) {
      return const _HoldingsSkeleton();
    }

    if (controller.error != null && controller.holdings.isEmpty) {
      return _ErrorState(error: controller.error!, onRetry: controller.loadAll);
    }

    return Stack(
      children: [
        RefreshIndicator(
          color: AppColors.neonCyan,
          backgroundColor: context.colors.surfaceElevated,
          onRefresh: controller.refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HeroSummarySection(controller: controller),
                const SizedBox(height: 16),
                WealthEvolutionBarCard(controller: controller),
                const SizedBox(height: 16),
                AssetAllocationCard(
                  allocation: controller.allocation,
                  totalValue: controller.summary.currentValue,
                ),
                const SizedBox(height: 16),
                HoldingsSection(holdings: controller.holdings, totalPortfolioValue: controller.summary.currentValue),
              ],
            ),
          ),
        ),
        Positioned(
          right: 4,
          bottom: 8,
          child: QuickActionsFab(
            onBuy: () => _openConfigure(context),
            onSell: () => GameSnack.show(context, 'Venda de ativos em breve, Comandante.'),
            onRebalance: () => GameSnack.showWithHaptic(
              context,
              'Veja a % da carteira e a meta de cada categoria nos cartões abaixo.',
            ),
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
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Center(
      child: GlassCard(
        backgroundColor: tokens.surface.withValues(alpha: context.isDarkMode ? 0.6 : 0.94),
        borderColor: tokens.error.withValues(alpha: 0.4),
        borderRadius: 24,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.satellite_alt, size: 56, color: tokens.error),
              const SizedBox(height: 16),
              Text(
                'Falha de Comunicação',
                style: TextStyle(color: tokens.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Não foi possível carregar seu portfólio.\n$error',
                textAlign: TextAlign.center,
                style: TextStyle(color: tokens.textSecondary, fontSize: 13),
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

class _HoldingsSkeleton extends StatelessWidget {
  const _HoldingsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _bar(context, height: 64),
        const SizedBox(height: 16),
        _bar(context, height: 300),
      ],
    );
  }

  Widget _bar(BuildContext context, {required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: context.colors.surface.withValues(alpha: context.isDarkMode ? 0.5 : 0.94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.border),
      ),
    );
  }
}
