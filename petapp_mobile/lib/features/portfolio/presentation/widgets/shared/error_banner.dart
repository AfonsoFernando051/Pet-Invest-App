import 'package:flutter/material.dart';
import 'package:petapp_mobile/core/constants/app_colors.dart';
import 'package:petapp_mobile/core/widgets/glass_card.dart';

/// Small non-blocking banner shown above a tab's content when a refresh
/// fails but cached data is still being displayed — used by Home, Proventos
/// and Missões so a transient network hiccup doesn't replace the whole
/// screen with an error state.
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      backgroundColor: AppColors.negativeRed.withValues(alpha: 0.1),
      borderColor: AppColors.negativeRed.withValues(alpha: 0.4),
      borderRadius: 14,
      borderWidth: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.satellite_alt, color: AppColors.negativeRed, size: 18),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Não foi possível atualizar seus dados. Puxe para atualizar.',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.negativeRed, size: 18),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
