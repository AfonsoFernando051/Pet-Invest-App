import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class LoginBackground extends StatelessWidget {
  const LoginBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.backgroundDark,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Nebula Image
          Image.asset(
            'assets/images/bg_nebula.png',
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            color: AppColors.neonCyan.withValues(alpha: 0.2),
            colorBlendMode: BlendMode.overlay,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.spaceDark,
                      AppColors.spacePurple,
                      AppColors.spaceBlue,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              );
            },
          ),
          // Cinematic Vignette Overlay
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  Colors.transparent,
                  AppColors.spaceDark.withValues(alpha: 0.5),
                  AppColors.spaceDark.withValues(alpha: 0.95),
                ],
                stops: const [0.3, 0.8, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
