import 'package:flutter/material.dart';
import 'package:petapp_mobile/core/constants/app_colors.dart';
import 'package:petapp_mobile/features/portfolio/domain/entities/dividend_event.dart';
import 'package:petapp_mobile/features/portfolio/presentation/widgets/dividend_event_tile.dart';

/// Bell-icon notification panel — real, provider-confirmed upcoming dividend
/// / JCP / yield payments for the user's real holdings (the same
/// [DividendEvent] data backing `DividendRadarSection` on the Proventos tab,
/// just surfaced app-wide via the AppBar instead of gated behind that tab).
/// Reuses [DividendEventTile] rather than inventing a second row layout for
/// the same data — matches AI_RULES.md's "reuse before you invent".
class DividendNotificationsSheet extends StatelessWidget {
  const DividendNotificationsSheet({
    super.key,
    required this.isLoading,
    required this.error,
    required this.upcoming,
    required this.onRetry,
  });

  final bool isLoading;
  final String? error;
  final List<DividendEvent> upcoming;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.spaceBlue,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      child: SafeArea(
        top: false,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.notifications_outlined, color: AppColors.neonCyan, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Notificações · Próximos Proventos',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Pagamentos de dividendos, JCP e rendimentos já confirmados pela B3 para os ativos que você possui.',
              style: TextStyle(color: AppColors.subtleText.withValues(alpha: 0.8), fontSize: 11),
            ),
            const SizedBox(height: 16),
            _buildBody(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading && upcoming.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator(color: AppColors.neonCyan, strokeWidth: 2)),
      );
    }

    if (error != null && upcoming.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            const Icon(Icons.satellite_alt, color: AppColors.negativeRed, size: 32),
            const SizedBox(height: 10),
            const Text(
              'Não foi possível carregar suas notificações.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, color: AppColors.neonCyan, size: 16),
              label: const Text('Tentar novamente', style: TextStyle(color: AppColors.neonCyan)),
            ),
          ],
        ),
      );
    }

    if (upcoming.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Icon(Icons.notifications_off_outlined, color: AppColors.subtleText.withValues(alpha: 0.6), size: 32),
            const SizedBox(height: 10),
            Text(
              'Nenhum provento confirmado a caminho para os seus ativos no momento.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.subtleText, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [for (final event in upcoming) DividendEventTile(event: event)],
    );
  }
}
