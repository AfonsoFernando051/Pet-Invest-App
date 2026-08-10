import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petapp_mobile/core/constants/app_colors.dart';
import 'package:petapp_mobile/core/di/dependency_injection.dart';
import 'package:petapp_mobile/features/asset_details/domain/entities/asset_data_status.dart';
import 'package:petapp_mobile/features/asset_details/presentation/controllers/asset_details_controller.dart';
import 'package:petapp_mobile/features/asset_details/presentation/widgets/asset_education_section.dart';
import 'package:petapp_mobile/features/asset_details/presentation/widgets/asset_header.dart';
import 'package:petapp_mobile/features/asset_details/presentation/widgets/concentration_warning.dart';
import 'package:petapp_mobile/features/asset_details/presentation/widgets/dividend_history_section.dart';
import 'package:petapp_mobile/features/asset_details/presentation/widgets/key_indicators_section.dart';
import 'package:petapp_mobile/features/asset_details/presentation/widgets/pet_teacher_widget.dart';
import 'package:petapp_mobile/features/asset_details/presentation/widgets/portfolio_context_card.dart';
import 'package:petapp_mobile/features/asset_details/presentation/widgets/user_position_card.dart';
import 'package:petapp_mobile/features/portfolio/domain/entities/holding.dart';

/// Full-screen asset details page — the core of the Real Asset Intelligence
/// feature. Replaces the previous [AssetDetailsSheet] bottom sheet with a
/// full-screen, scrollable, educational experience.
///
/// Opens instantly with cached [Holding] data, then enriches from the backend.
/// The layout dynamically adapts to the asset type (stock/FII/ETF).
class AssetDetailsScreen extends StatefulWidget {
  const AssetDetailsScreen({
    super.key,
    required this.ticker,
    this.holding,
  });

  final String ticker;
  final Holding? holding;

  @override
  State<AssetDetailsScreen> createState() => _AssetDetailsScreenState();
}

class _AssetDetailsScreenState extends State<AssetDetailsScreen> {
  late final AssetDetailsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AssetDetailsController(
      repository: DI.assetDetailsRepository,
    );
    _controller.addListener(_onUpdate);
    _controller.loadAssetDetails(widget.ticker, holding: widget.holding);
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.spaceDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.spaceDark, AppColors.spacePurple, AppColors.spaceBlue],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final asset = _controller.assetDetails;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          ),
          Expanded(
            child: Text(
              asset?.ticker ?? widget.ticker,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Data status indicator
          _DataStatusBadge(status: asset?.dataStatus ?? AssetDataStatus.unavailable),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final asset = _controller.assetDetails;

    if (_controller.isLoading && asset == null) {
      return const _AssetDetailsSkeleton();
    }

    if (_controller.error != null && asset == null) {
      return _ErrorState(
        error: _controller.error!,
        onRetry: _controller.refresh,
      );
    }

    if (asset == null) {
      return const Center(
        child: Text(
          'Ativo não encontrado.',
          style: TextStyle(color: AppColors.subtleText),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.neonCyan,
      backgroundColor: AppColors.spaceBlue,
      onRefresh: _controller.refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          // ── Header: ticker, name, price, change ─────────────
          AssetHeader(asset: asset),

          const SizedBox(height: 16),

          // ── User Position (if owned) ────────────────────────
          if (asset.isOwned) ...[
            UserPositionCard(asset: asset),
            const SizedBox(height: 16),
          ],

          // ── Key Indicators (type-aware) ─────────────────────
          KeyIndicatorsSection(asset: asset),

          const SizedBox(height: 16),

          // ── Portfolio Context (if owned) ─────────────────────
          if (asset.isOwned) ...[
            PortfolioContextCard(asset: asset),
            const SizedBox(height: 16),
          ],

          // ── Concentration Warning (if concentrated) ─────────
          if (asset.isOwned && _isConcentrated(asset)) ...[
            ConcentrationWarning(asset: asset),
            const SizedBox(height: 16),
          ],

          // ── Dividend History ─────────────────────────────────
          if (asset.recentDividends.isNotEmpty) ...[
            DividendHistorySection(asset: asset),
            const SizedBox(height: 16),
          ],

          // ── Educational Section ─────────────────────────────
          AssetEducationSection(asset: asset),

          const SizedBox(height: 16),

          // ── Pet Teacher ─────────────────────────────────────
          PetTeacherWidget(asset: asset),

          // ── Loading indicator for background refresh ────────
          if (_controller.isLoading && asset.dataStatus == AssetDataStatus.cached)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.neonCyan,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _isConcentrated(dynamic asset) {
    return asset.userPosition != null && asset.userPosition!.portfolioWeight > 20;
  }
}

// ── Data Status Badge ───────────────────────────────────────────────────

class _DataStatusBadge extends StatelessWidget {
  const _DataStatusBadge({required this.status});

  final AssetDataStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      AssetDataStatus.fresh => (AppColors.positiveGreen, 'Ao vivo'),
      AssetDataStatus.cached => (AppColors.warningAmber, 'Cache'),
      AssetDataStatus.delayed => (AppColors.warningAmber, 'Atrasado'),
      AssetDataStatus.partial => (AppColors.warningAmber, 'Parcial'),
      AssetDataStatus.unavailable => (AppColors.negativeRed, 'Indisponível'),
      AssetDataStatus.error => (AppColors.negativeRed, 'Erro'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ── Skeleton ─────────────────────────────────────────────────────────────

class _AssetDetailsSkeleton extends StatelessWidget {
  const _AssetDetailsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _bar(height: 120),
        const SizedBox(height: 16),
        _bar(height: 100),
        const SizedBox(height: 16),
        _bar(height: 80),
        const SizedBox(height: 16),
        _bar(height: 140),
      ],
    );
  }

  Widget _bar({required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.spaceDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
    );
  }
}

// ── Error State ──────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final String error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.satellite_alt, size: 56, color: AppColors.negativeRed),
            const SizedBox(height: 16),
            const Text(
              'Não foi possível carregar este ativo',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(color: AppColors.subtleText, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Tentar novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonViolet,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
