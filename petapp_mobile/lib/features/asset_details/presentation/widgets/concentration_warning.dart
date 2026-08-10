import 'package:flutter/material.dart';
import 'package:petapp_mobile/core/constants/app_colors.dart';
import 'package:petapp_mobile/core/widgets/glass_card.dart';
import 'package:petapp_mobile/features/asset_details/domain/entities/asset_details.dart';

/// Educational concentration warning — shown when an asset represents a
/// significant portion of the user's portfolio. This is descriptive,
/// NOT prescriptive — it never says "sell" or "buy".
class ConcentrationWarning extends StatelessWidget {
  const ConcentrationWarning({super.key, required this.asset});

  final AssetDetails asset;

  @override
  Widget build(BuildContext context) {
    final pos = asset.userPosition;
    if (pos == null) return const SizedBox.shrink();

    return GlassCard(
      backgroundColor: AppColors.warningAmber.withValues(alpha: 0.06),
      borderColor: AppColors.warningAmber.withValues(alpha: 0.2),
      borderRadius: 18,
      borderWidth: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.warningAmber, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Concentração',
                  style: TextStyle(
                    color: AppColors.warningAmber,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${asset.displayName} representa ${pos.portfolioWeight.toStringAsFixed(1)}% '
              'da sua carteira, o que é uma porção relativamente grande.',
              style: TextStyle(color: AppColors.subtleText, fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 8),
            Text(
              'Concentração não é automaticamente ruim, mas é útil entender '
              'quanto do seu portfólio depende de um único ativo ou setor.',
              style: TextStyle(
                color: AppColors.subtleText.withValues(alpha: 0.7),
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
