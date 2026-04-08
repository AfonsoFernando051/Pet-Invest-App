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
             const Text('Transações Recentes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
             const SizedBox(height: 16),
             _buildTransactionRow('PETR4', 'Flrx - 1,028%', 'R\$ 250.00', '22/03/2022', false),
             const Divider(color: Colors.white24, height: 24),
             _buildTransactionRow('WEGE3', 'Prx - 1,875%', '+R\$ 180.00', '22/04/2022', true),
           ],
         ),
       )
    );
  }

  Widget _buildTransactionRow(String ticker, String desc, String value, String date, bool isPositive) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ticker, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(value, style: TextStyle(color: isPositive ? Colors.greenAccent : Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            Text(date, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}
