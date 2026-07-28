import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';

class RecentTransactions extends StatelessWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      backgroundColor: AppColors.spaceDark.withValues(alpha: 0.6),
      borderColor: AppColors.neonCyan.withValues(alpha: 0.2),
      borderRadius: 16,
      borderWidth: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Últimas Missões',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Ver todas →',
                  style: TextStyle(
                    color: AppColors.neonCyan.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMissionRow(
              ticker: 'PETR4',
              desc: 'Compra executada',
              value: 'R\$ 250,00',
              date: '22/03/22',
              xp: '+8 XP',
              badgeColor: AppColors.negativeRed,
              badgeIcon: Icons.shopping_cart_outlined,
              isPositive: false,
            ),
            Divider(color: Colors.white.withValues(alpha: 0.1), height: 24),
            _buildMissionRow(
              ticker: 'WEGE3',
              desc: 'Dividendo recebido',
              value: '+R\$ 180,00',
              date: '22/04/22',
              xp: '+12 XP',
              badgeColor: AppColors.positiveGreen,
              badgeIcon: Icons.emoji_events_outlined,
              isPositive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionRow({
    required String ticker,
    required String desc,
    required String value,
    required String date,
    required String xp,
    required Color badgeColor,
    required IconData badgeIcon,
    required bool isPositive,
  }) {
    return Row(
      children: [
        // Badge icon
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
          ),
          child: Icon(badgeIcon, color: badgeColor, size: 18),
        ),
        const SizedBox(width: 12),

        // Ticker + description
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ticker,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                desc,
                style: const TextStyle(color: AppColors.subtleText, fontSize: 12),
              ),
            ],
          ),
        ),

        // Value + XP + date
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                color: isPositive ? AppColors.positiveGreen : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            Row(
              children: [
                Text(
                  xp,
                  style: TextStyle(
                    color: AppColors.neonCyan.withValues(alpha: 0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  date,
                  style: const TextStyle(color: AppColors.subtleText, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
