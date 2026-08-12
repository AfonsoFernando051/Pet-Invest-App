import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/app_theme.dart';
import 'package:petrimonium/core/theme/theme_controller.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/navigation/start_route_resolver.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/auth/presentation/screens/login_screen.dart';
import 'package:petrimonium/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:petrimonium/features/investment/presentation/screens/portfolio_choice_screen.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/tutorial_screen.dart';
import 'package:petrimonium/features/pet/presentation/screens/financial_goal_screen.dart';
import 'package:petrimonium/features/pet/presentation/screens/pet_configuration_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Translator.load();
  await ThemeController.load();
  await DI.onboardingStateRepository.incrementSessionCount();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuilds the whole app when the user switches language or theme in
    // Settings, since screens read Translator.translate()/context.colors
    // directly at build time.
    return ValueListenableBuilder<String>(
      valueListenable: Translator.languageNotifier,
      builder: (context, _, __) => ValueListenableBuilder<ThemeMode>(
        valueListenable: ThemeController.themeModeNotifier,
        builder: (context, themeMode, __) => MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          // Smooth, fast, non-flashy cross-fade on Light/Dark/System switch
          // (MaterialApp animates `theme`/`darkTheme` changes internally).
          themeAnimationDuration: const Duration(milliseconds: 280),
          themeAnimationCurve: Curves.easeOutCubic,
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
      ),
    );
  }
}

/// Branded loading splash — replaces the plain white CircularProgressIndicator.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: tokens.backgroundPrimary,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [AppColors.spaceDark, AppColors.spacePurple, AppColors.spaceBlue]
                : [tokens.backgroundPrimary, tokens.primaryContainer, tokens.backgroundSecondary],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/generated_fox.png',
                height: 120,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.pets,
                  size: 80,
                  color: tokens.primary,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  color: tokens.primary,
                  strokeWidth: 2,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Inicializando Módulo de Comandante...',
                style: GoogleFonts.outfit(
                  color: tokens.textSecondary,
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
