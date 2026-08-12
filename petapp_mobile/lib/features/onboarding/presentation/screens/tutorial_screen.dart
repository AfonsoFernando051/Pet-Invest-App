import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/cosmic_background.dart';
import 'package:petrimonium/core/widgets/game_button.dart';
import 'package:petrimonium/features/investment/presentation/screens/portfolio_choice_screen.dart';

class _TutorialStep {
  const _TutorialStep({required this.icon, required this.titleKey, required this.bodyKey});
  final IconData icon;
  final String titleKey;
  final String bodyKey;
}

const _steps = [
  _TutorialStep(
    icon: Icons.rocket_launch,
    titleKey: AppStrings.tutorialStep1Title,
    bodyKey: AppStrings.tutorialStep1Body,
  ),
  _TutorialStep(
    icon: Icons.menu_book_outlined,
    titleKey: AppStrings.tutorialStep2Title,
    bodyKey: AppStrings.tutorialStep2Body,
  ),
  _TutorialStep(
    icon: Icons.diamond_outlined,
    titleKey: AppStrings.tutorialStep3Title,
    bodyKey: AppStrings.tutorialStep3Body,
  ),
];

/// Onboarding's "Complete Tutorial" step — a short, skippable walkthrough of
/// the app's core loop (missions, lessons, and the fact that the portfolio
/// step ahead is optional) before the player reaches Home.
class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final _pageController = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await DI.onboardingStateRepository.completeTutorial();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PortfolioChoiceScreen()),
      );
    }
  }

  void _next() {
    if (_index == _steps.length - 1) {
      _finish();
      return;
    }
    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _steps.length - 1;
    final tokens = context.colors;
    return Scaffold(
      body: CosmicBackground(
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextButton(
                    onPressed: _finish,
                    child: Text(
                      Translator.translate(AppStrings.tutorialSkip),
                      style: TextStyle(color: tokens.textSecondary),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _steps.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) => _buildStep(context, _steps[i]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_steps.length, (i) {
                    final active = i == _index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: active ? 22 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: active ? AppColors.neonCyan : tokens.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: GameButton(
                  label: isLast ? Translator.translate(AppStrings.tutorialEnterHome) : Translator.translate(AppStrings.tutorialNext),
                  icon: Icons.arrow_forward,
                  iconTrailing: true,
                  pulse: true,
                  onPressed: _next,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, _TutorialStep step) {
    final tokens = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.neonCyan.withValues(alpha: 0.12),
              border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.4)),
            ),
            child: Icon(step.icon, color: AppColors.neonCyan, size: 44),
          ),
          const SizedBox(height: 32),
          Text(
            Translator.translate(step.titleKey),
            textAlign: TextAlign.center,
            style: TextStyle(color: tokens.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            Translator.translate(step.bodyKey),
            textAlign: TextAlign.center,
            style: TextStyle(color: tokens.textSecondary, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}
