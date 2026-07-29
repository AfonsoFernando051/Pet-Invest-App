import 'package:flutter/material.dart';
import 'package:petapp_mobile/core/di/dependency_injection.dart';
import 'package:petapp_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:petapp_mobile/features/investment/presentation/screens/portfolio_choice_screen.dart';
import 'package:petapp_mobile/features/onboarding/presentation/screens/tutorial_screen.dart';
import 'package:petapp_mobile/features/pet/presentation/screens/financial_goal_screen.dart';
import 'package:petapp_mobile/features/pet/presentation/screens/pet_configuration_screen.dart';

/// Single source of truth for "where should a logged-in user land right
/// now?" — evaluated both at cold start (`main.dart`) and immediately after
/// login/signup (`AuthNavigationUtils`). Keeping this logic in one place is
/// what guarantees the two entry points can never disagree about which
/// onboarding step is still outstanding.
enum OnboardingRoute { meetPet, financialGoal, tutorial, portfolioChoice, home }

/// Walks the mandatory onboarding chain in order — pet configured & named,
/// financial goal chosen, tutorial completed, portfolio step resolved — and
/// returns the first incomplete step, or [OnboardingRoute.home] once every
/// step is done. Never skips a step, regardless of which entry point calls it.
Future<OnboardingRoute> resolveOnboardingRoute() async {
  final hasPet = await DI.petRepository.getPetStatus();
  final profile = await DI.mascotRepository.loadProfile();
  final hasName = profile.name != null && profile.name!.trim().isNotEmpty;
  if (!hasPet || !hasName) return OnboardingRoute.meetPet;

  final hasSetGoal = await DI.onboardingStateRepository.hasSetGoal();
  if (!hasSetGoal) return OnboardingRoute.financialGoal;

  final tutorialDone = await DI.onboardingStateRepository.isTutorialCompleted();
  if (!tutorialDone) return OnboardingRoute.tutorial;

  final portfolioStepDone = await DI.onboardingStateRepository.isPortfolioStepDone();
  if (!portfolioStepDone) return OnboardingRoute.portfolioChoice;

  return OnboardingRoute.home;
}

/// Builds the screen for a resolved [OnboardingRoute].
Widget buildScreenForOnboardingRoute(OnboardingRoute route) {
  switch (route) {
    case OnboardingRoute.meetPet:
      return const PetConfigurationScreen();
    case OnboardingRoute.financialGoal:
      return const FinancialGoalScreen();
    case OnboardingRoute.tutorial:
      return const TutorialScreen();
    case OnboardingRoute.portfolioChoice:
      return const PortfolioChoiceScreen();
    case OnboardingRoute.home:
      return const DashboardScreen();
  }
}
