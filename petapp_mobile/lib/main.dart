import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petapp_mobile/core/constants/app_colors.dart';
import 'package:petapp_mobile/core/di/dependency_injection.dart';
import 'package:petapp_mobile/core/navigation/start_route_resolver.dart';
import 'package:petapp_mobile/core/utils/translator.dart';
import 'package:petapp_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:petapp_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:petapp_mobile/features/investment/presentation/screens/portfolio_choice_screen.dart';
import 'package:petapp_mobile/features/onboarding/presentation/screens/tutorial_screen.dart';
import 'package:petapp_mobile/features/pet/presentation/screens/financial_goal_screen.dart';
import 'package:petapp_mobile/features/pet/presentation/screens/pet_configuration_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Translator.load();
  await DI.onboardingStateRepository.incrementSessionCount();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final outfitTextTheme = GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme);

    // Rebuilds the whole app when the user switches language in Settings,
    // since screens read Translator.translate() directly at build time.
    return ValueListenableBuilder<String>(
      valueListenable: Translator.languageNotifier,
      builder: (context, _, __) => MaterialApp(
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
          future: StartRouteResolver().resolve(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _SplashScreen();
            }

            switch (snapshot.data) {
              case StartRoute.home:
                return const DashboardScreen();
              case StartRoute.portfolioChoice:
                return const PortfolioChoiceScreen();
              case StartRoute.tutorial:
                return const TutorialScreen();
              case StartRoute.financialGoal:
                return const FinancialGoalScreen();
              case StartRoute.meetPet:
                return const PetConfigurationScreen();
              case StartRoute.login:
              case null:
                return const LoginScreen();
            }
          },
        ),
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
