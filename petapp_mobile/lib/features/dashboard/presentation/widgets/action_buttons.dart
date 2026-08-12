import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/game_button.dart';
import '../../../academy/presentation/screens/academy_home_screen.dart';
import '../../../investment/presentation/screens/investment_configuration_screen.dart';
import '../../../pet/presentation/mascot/controllers/mascot_controller.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key, required this.mascotController});

  final MascotController mascotController;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Primary CTA — Alimentar / Investir
        Expanded(
          child: _buildPrimaryButton(
            context,
            title: 'Alimentar',
            subtitle: 'Investir',
            icon: Icons.pets,
            colors: [AppColors.neonViolet, AppColors.neonPink],
            onTap: () {
              // GameButton already fires haptic feedback on tap.
              Navigator.of(context).push(
                _fadeRoute(const InvestmentConfigurationScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 10),

        // Secondary CTA — Treinar / Analisar: entry point into the Academy.
        Expanded(
          child: _buildSecondaryButton(
            context,
            title: 'Treinar',
            subtitle: 'Aprender',
            icon: Icons.menu_book_outlined,
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).push(
                _fadeRoute(
                  AcademyHomeScreen(mascotController: mascotController),
                  name: 'academy_home',
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 10),

        // Tertiary CTA — Missões / Metas (outlined)
        Expanded(
          child: _buildTertiaryButton(
            context,
            title: 'Missões',
            subtitle: 'Metas',
            icon: Icons.flag_outlined,
            onTap: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sistema de Missões em breve!')),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Primary — GameButton chrome (gradient/glow/pulse/press) ─────────────
  Widget _buildPrimaryButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> colors,
    VoidCallback? onTap,
  }) {
    return GameButton.custom(
      onPressed: onTap,
      colors: colors,
      pulse: true,
      borderRadius: 20,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: _buttonContent(icon, title, subtitle),
      ),
    );
  }

  // ── Secondary — cooler gradient, smaller shadow ──────────────────────────
  Widget _buildSecondaryButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.spaceBlue, AppColors.neonViolet],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonViolet.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
            child: _buttonContent(icon, title, subtitle),
          ),
        ),
      ),
    );
  }

  // ── Tertiary — outlined, no fill ─────────────────────────────────────────
  Widget _buildTertiaryButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.neonCyan.withValues(alpha: 0.55),
              width: 1.5,
            ),
            color: AppColors.neonCyan.withValues(alpha: 0.06),
          ),
          child: _buttonContent(icon, title, subtitle),
        ),
      ),
    );
  }

  Widget _buttonContent(IconData icon, String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(width: 6),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.subtleText,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Route _fadeRoute(Widget page, {String? name}) {
    return PageRouteBuilder(
      settings: RouteSettings(name: name),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        ),
      ),
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}
