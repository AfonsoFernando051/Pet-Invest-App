import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petapp_mobile/core/constants/app_colors.dart';
import 'package:petapp_mobile/core/theme/app_color_tokens.dart';
import 'package:petapp_mobile/core/utils/game_snack.dart';
import 'package:petapp_mobile/core/widgets/glass_card.dart';
import 'package:petapp_mobile/features/investment/presentation/screens/investment_configuration_screen.dart';
import 'package:petapp_mobile/features/portfolio/presentation/controllers/portfolio_controller.dart';
import 'package:petapp_mobile/features/portfolio/presentation/widgets/holdings_section.dart';
import 'package:petapp_mobile/features/portfolio/presentation/widgets/quick_actions_fab.dart';

/// The "Carteira" (Portfolio) tab — dedicated exclusively to managing
/// holdings (Investidor10-inspired: grouped by category, collapsible,
/// expandable to full asset detail). Dashboard charts, insights, passive
/// income and gamification now live on the Home tab instead — this screen
/// has a single responsibility: let the user see and act on what they own.
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
                _PortfolioHeader(controller: controller),
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

/// Compact "what am I managing" strip — count, total value and overall
/// return — so the holdings list below has context without pulling in the
/// full Home dashboard's charts.
class _PortfolioHeader extends StatelessWidget {
  const _PortfolioHeader({required this.controller});

  final PortfolioController controller;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final s = controller.summary;
    final isPositive = s.totalGain >= 0;

    return GlassCard(
      backgroundColor: tokens.surface.withValues(alpha: context.isDarkMode ? 0.55 : 0.94),
      borderColor: AppColors.neonCyan.withValues(alpha: 0.25),
      borderRadius: 18,
      borderWidth: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            _stat(context, '${s.totalAssets}', 'Ativos'),
            _divider(context),
            _stat(context, _compact(s.currentValue), 'Valor Atual'),
            _divider(context),
            _stat(
              context,
              '${isPositive ? '+' : ''}${s.totalGainPercent.toStringAsFixed(1)}%',
              'Retorno Total',
              color: isPositive ? tokens.success : tokens.error,
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider(BuildContext context) => Container(width: 1, height: 32, color: context.colors.divider);

  Widget _stat(BuildContext context, String value, String label, {Color? color}) {
    final tokens = context.colors;
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color ?? tokens.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: tokens.textSecondary, fontSize: 10)),
        ],
      ),
    );
  }

  String _compact(double value) {
    if (value.abs() >= 1000) return 'R\$ ${(value / 1000).toStringAsFixed(1)}K';
    return 'R\$ ${value.toStringAsFixed(0)}';
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
