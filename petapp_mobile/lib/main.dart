import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petapp_mobile/core/constants/app_colors.dart';
import 'package:petapp_mobile/core/di/dependency_injection.dart';
import 'package:petapp_mobile/core/navigation/onboarding_route.dart';
import 'package:petapp_mobile/core/network/api_client.dart';
import 'package:petapp_mobile/core/utils/translator.dart';
import 'package:petapp_mobile/features/auth/presentation/screens/login_screen.dart';

/// Global navigator key so app-wide events (e.g. a 401 from [ApiClient]
/// meaning the session expired) can redirect to the login screen without
/// needing a [BuildContext] from deep inside the widget tree.
final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Translator.load();
  await DI.onboardingStateRepository.incrementSessionCount();
  ApiClient.onUnauthorized = _handleSessionExpired;
  runApp(const MyApp());
}

/// Called whenever the backend responds 401 to an authenticated request.
/// Clears the stale token and bounces the user back to login so the app
/// never sits on a screen backed by a session that no longer exists.
Future<void> _handleSessionExpired() async {
  await DI.authRepository.logout();
  navigatorKey.currentState?.pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (route) => false,
  );
}

/// The redesigned onboarding sequence: configure the pet (species + name,
/// in one screen right after registering) and pick a goal — all
/// emotional/low-friction steps — before the (now fully optional) portfolio
/// step. The old risk-assessment questionnaire (`OnboardingScreen`) no
/// longer gates this chain; it's reachable later as a suggested action on
/// Home, since it's financial data collection too and shouldn't block
/// reaching Home in under a minute.
///
/// A `null` result means the user isn't logged in. Both this and the
/// post-login redirect in `AuthNavigationUtils` resolve through the shared
/// `resolveOnboardingRoute()`, so the two entry points can never disagree
/// about which onboarding step is still outstanding.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<OnboardingRoute?> _getStartRoute() async {
    final loggedIn = await DI.authRepository.isLoggedIn();
    if (!loggedIn) return null;

    try {
      return await resolveOnboardingRoute();
    } catch (_) {
      await DI.authRepository.logout();
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final outfitTextTheme = GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme);

    // Rebuilds the whole app when the user switches language in Settings,
    // since screens read Translator.translate() directly at build time.
    return ValueListenableBuilder<String>(
      valueListenable: Translator.languageNotifier,
      builder: (context, _, __) => MaterialApp(
        navigatorKey: navigatorKey,
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
        home: FutureBuilder<OnboardingRoute?>(
          future: _getStartRoute(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _SplashScreen();
            }

            final route = snapshot.data;
            if (route == null) return const LoginScreen();
            return buildScreenForOnboardingRoute(route);
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
