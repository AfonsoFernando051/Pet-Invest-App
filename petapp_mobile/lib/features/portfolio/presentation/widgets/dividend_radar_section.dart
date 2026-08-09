import 'package:flutter/material.dart';
import 'package:petapp_mobile/core/constants/app_colors.dart';
import 'package:petapp_mobile/core/widgets/glass_card.dart';
import 'package:petapp_mobile/features/portfolio/domain/entities/dividend_event.dart';
import 'package:petapp_mobile/features/portfolio/presentation/widgets/dividend_event_tile.dart';
import 'package:petapp_mobile/features/portfolio/presentation/widgets/shared/section_label.dart';

/// "Radar de Dividendos" — real, provider-confirmed dividend/JCP/yield
/// payments for the user's real holdings (contrast with the "estimated"
/// `PassiveIncomeCard` above it, which is a projection). Every figure here
/// traces back to a Brapi-confirmed corporate action, scaled by the
/// quantity the user actually held at the relevant date — see
/// `GetDividendRadarUseCaseImpl` on the backend for how that's guaranteed.
class DividendRadarSection extends StatelessWidget {
  const DividendRadarSection({
    super.key,
    required this.isLoading,
    required this.error,
    required this.radar,
    required this.onRetry,
  });

  final bool isLoading;
  final String? error;
  final DividendRadar radar;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      backgroundColor: AppColors.spaceDark.withValues(alpha: 0.6),
      borderColor: AppColors.positiveGreen.withValues(alpha: 0.3),
      borderRadius: 20,
      borderWidth: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel('RADAR DE DIVIDENDOS (CONFIRMADO)'),
            const SizedBox(height: 4),
            Text(
              'Pagamentos reais de dividendos, JCP e rendimentos confirmados pela B3 para os ativos que você possui.',
              style: TextStyle(color: AppColors.subtleText.withValues(alpha: 0.8), fontSize: 10),
            ),
            const SizedBox(height: 12),
            _buildBody(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading && radar.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(color: AppColors.neonCyan, strokeWidth: 2)),
      );
    }

    if (error != null && radar.isEmpty) {
      return _RadarErrorState(onRetry: onRetry);
    }

    if (radar.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'Nenhum provento confirmado encontrado ainda para seus ativos. Assim que a B3 confirmar um pagamento para algo que você possui, ele aparece aqui.',
          style: TextStyle(color: AppColors.subtleText, fontSize: 12),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (radar.upcoming.isNotEmpty) ...[
          _subLabel('PRÓXIMOS', AppColors.goldenBorder),
          _Divider(),
          for (final event in radar.upcoming) DividendEventTile(event: event),
        ],
        if (radar.history.isNotEmpty) ...[
          if (radar.upcoming.isNotEmpty) const SizedBox(height: 12),
          _subLabel('HISTÓRICO RECENTE', AppColors.positiveGreen),
          _Divider(),
          for (final event in radar.history) DividendEventTile(event: event),
        ],
      ],
    );
  }

  Widget _subLabel(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        label,
        style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: Colors.white.withValues(alpha: 0.06));
  }
}

class _RadarErrorState extends StatelessWidget {
  const _RadarErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.satellite_alt, color: AppColors.negativeRed, size: 18),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Não foi possível carregar o radar de dividendos.',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.negativeRed, size: 18),
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
