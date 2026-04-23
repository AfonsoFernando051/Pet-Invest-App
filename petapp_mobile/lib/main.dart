import 'package:flutter/material.dart';
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
      // Token might be invalid/expired; clear it and force login.
      await DI.authRepository.logout();
      return StartRoute.login;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<StartRoute>(
        future: _getStartRoute(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
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
