import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/widgets/cosmic_background.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/settings/presentation/screens/settings_screen.dart';

/// The "Perfil" experience — previously its own bottom-nav tab, now reached
/// via the AppBar's config/gear icon instead (the Perfil tab was removed;
/// the gear icon is now responsible for everything it used to cover).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
    final tokens = context.colors;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Perfil', style: TextStyle(color: tokens.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: tokens.textPrimary),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
      ),
      body: CosmicBackground(
        child: SafeArea(
          child: Center(
            child: GlassCard(
              backgroundColor: tokens.surface.withValues(alpha: context.isDarkMode ? 0.6 : 0.94),
              borderColor: AppColors.neonPink.withValues(alpha: 0.3),
              borderRadius: 24,
              borderWidth: 1,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.manage_accounts, size: 64, color: AppColors.neonPink.withValues(alpha: 0.7)),
                    const SizedBox(height: 16),
                    Text(
                      'Perfil do Comandante',
                      style: TextStyle(color: tokens.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Conquistas em breve.\nGerencie idioma e conta nas configurações.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: tokens.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.settings_outlined, color: AppColors.neonPink),
                      label: const Text(
                        'Configurações',
                        style: TextStyle(color: AppColors.neonPink, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.neonPink),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(context).push(_fadeRoute(const SettingsScreen()));
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
