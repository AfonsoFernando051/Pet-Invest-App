import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:petapp_mobile/core/constants/app_colors.dart';
import 'package:petapp_mobile/features/auth/presentation/widgets/login_background.dart';
import 'package:petapp_mobile/features/onboarding/presentation/widgets/onboarding_form.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.spaceDark, // Update to spaceDark
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Seu Perfil de Investidor Pet',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Stack(
        children: [
          const LoginBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Background graphic inside the card
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.4,
                          child: Image.asset(
                            'assets/images/questionary_space_paw.png',
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                          ),
                        ),
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: const OnboardingForm(),
                      ),
                      
                      // Bottom right star decoration - moved inside the card
                      Positioned(
                        bottom: 24,
                        right: 24,
                        child: Icon(
                          Icons.auto_awesome, 
                          color: Colors.white.withValues(alpha: 0.6),
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
        ],
      ),
    );
  }
}

