import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../investment/presentation/screens/investment_configuration_screen.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: _buildGradientButton(
            'Alimentar', 
            'Investir', 
            Icons.pets, 
            [const Color(0xFF8A2BE2), const Color(0xFFFF007F)],
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const InvestmentConfigurationScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildGradientButton(
            'Treinar', 
            'Analisar', 
            Icons.menu_book, 
            [const Color(0xFF8A2BE2), const Color(0xFFFF007F)],
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Análise de Ativos em construção...')));
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildGradientButton(
            'Missões', 
            'Metas', 
            Icons.flag, 
            [const Color(0xFF8A2BE2), AppColors.neonCyan],
            onTap: () {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sistema de Missões em breve!')));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGradientButton(String title, String subtitle, IconData icon, List<Color> colors, {VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: colors.last.withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 1)
            ]
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
