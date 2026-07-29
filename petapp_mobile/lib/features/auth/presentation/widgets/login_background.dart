import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/cosmic_background.dart';

class LoginBackground extends StatelessWidget {
  const LoginBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CosmicBackground(
      assetPath: 'assets/images/questionary_space_paw.png',
      darken: 0.2,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.spaceDark, AppColors.spacePurple, AppColors.spaceBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        );
      },
      child: const SizedBox.shrink(),
    );
  }
}
