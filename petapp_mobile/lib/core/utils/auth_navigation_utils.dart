import 'package:flutter/material.dart';
import 'package:petapp_mobile/core/di/dependency_injection.dart';
import 'package:petapp_mobile/core/navigation/onboarding_route.dart';
import 'package:petapp_mobile/features/auth/presentation/screens/login_screen.dart';

class AuthNavigationUtils {
  /// Routes a just-logged-in/just-registered user to wherever they actually
  /// belong. Delegates to the same `resolveOnboardingRoute()` used at cold
  /// start, so login never drops a user onto the Dashboard while a
  /// mandatory onboarding step (financial goal, tutorial, portfolio choice)
  /// is still outstanding.
  static Future<void> handlePostAuthRedirect(BuildContext context) async {
    OnboardingRoute route;
    try {
      route = await resolveOnboardingRoute();
    } catch (_) {
      if (!context.mounted) return;
      await DI.authRepository.logout();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (r) => false,
      );
      return;
    }

    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => buildScreenForOnboardingRoute(route)),
    );
  }
}
