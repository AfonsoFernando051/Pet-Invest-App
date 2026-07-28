import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petapp_mobile/core/constants/app_colors.dart';
import 'package:petapp_mobile/core/di/dependency_injection.dart';
import 'package:petapp_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:petapp_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:petapp_mobile/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:petapp_mobile/features/pet/presentation/screens/pet_configuration_screen.dart';

void main() {
  runApp(const MyApp());
}

enum StartRoute { login, onboarding, petConfig, home }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<StartRoute> _getStartRoute() async {
    final loggedIn = await DI.authRepository.isLoggedIn();
    if (!loggedIn) return StartRoute.login;

    try {
      final status = await DI.onboardingRepository.getStatus();
      if (!status.hasAnswered) return StartRoute.onboarding;

      final hasPet = await DI.petRepository.getPetStatus();
      if (!hasPet) return StartRoute.petConfig;

      return StartRoute.home;
    } catch (_) {
      await DI.authRepository.logout();
      return StartRoute.login;
    }
  }

  @override
  Widget build(BuildContext context) {
    final outfitTextTheme = GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        textTheme: outfitTextTheme,
        scaffoldBackgroundColor: AppColors.spaceDark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.neonCyan,
          secondary: AppColors.neonPurple,
          surface: AppColors.spaceBlue,
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: AppColors.spaceBlue,
          contentTextStyle: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      home: FutureBuilder<StartRoute>(
        future: _getStartRoute(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _SplashScreen();
          }

          final route = snapshot.data;
          if (route == StartRoute.home) return const DashboardScreen();
          if (route == StartRoute.petConfig) return const PetConfigurationScreen();
          if (route == StartRoute.onboarding) return const OnboardingScreen();
          return const LoginScreen();
        },
      ),
    );
  }
}

/// Branded loading splash — replaces the plain white CircularProgressIndicator.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.spaceDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.spaceDark, AppColors.spacePurple, AppColors.spaceBlue],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/generated_fox.png',
                height: 120,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.pets,
                  size: 80,
                  color: AppColors.neonCyan,
                ),
              ),
              const SizedBox(height: 32),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  color: AppColors.neonCyan,
                  strokeWidth: 2,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Inicializando Módulo de Comandante...',
                style: GoogleFonts.outfit(
                  color: AppColors.subtleText,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
