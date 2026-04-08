import 'package:flutter/material.dart';
import 'package:petapp_mobile/core/di/dependency_injection.dart';
import 'package:petapp_mobile/features/home/presentation/screens/home_screen.dart';
import 'package:petapp_mobile/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:petapp_mobile/features/pet/presentation/screens/pet_configuration_screen.dart';

class AuthNavigationUtils {
  static Future<void> handlePostAuthRedirect(BuildContext context) async {
    final status = await DI.onboardingRepository.getStatus();
    
    if (!context.mounted) return;
    
    if (!status.hasAnswered) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
      return;
    }

    final hasPet = await DI.petRepository.getPetStatus();
    
    if (!context.mounted) return;
    
    if (!hasPet) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PetConfigurationScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }
}
