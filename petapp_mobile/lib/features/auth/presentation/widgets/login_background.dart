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
            'assets/images/questionary_space_paw.png',
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
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
        ],
      ),
    );
  }
}
