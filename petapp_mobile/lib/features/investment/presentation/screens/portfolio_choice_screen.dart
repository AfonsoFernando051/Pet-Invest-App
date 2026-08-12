import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/game_button.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:petrimonium/features/investment/presentation/screens/investment_configuration_screen.dart';

/// Onboarding's final, deliberately non-blocking step: connect the
/// portfolio now, or skip and do it later. Every path below leads to Home —
/// there is no way to get stuck here, per the "skipping must never block
/// the user" product requirement.
class PortfolioChoiceScreen extends StatefulWidget {
  const PortfolioChoiceScreen({super.key});

  @override
  State<PortfolioChoiceScreen> createState() => _PortfolioChoiceScreenState();
}

class _PortfolioChoiceScreenState extends State<PortfolioChoiceScreen> {
  String? _petName;

  @override
  void initState() {
    super.initState();
    _loadPetName();
  }

  Future<void> _loadPetName() async {
    final profile = await DI.mascotRepository.loadProfile();
    if (mounted) setState(() => _petName = profile.name);
  }

  void _goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
      (route) => false,
    );
  }

  Future<void> _handleImport() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          Translator.translate(AppStrings.importComingSoonTitle),
          style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          Translator.translate(AppStrings.importComingSoonBody),
          style: TextStyle(color: context.colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(Translator.translate(AppStrings.okButton), style: const TextStyle(color: AppColors.neonCyan)),
          ),
        ],
      ),
    );
  }

  void _handleAddManually() {
    // `InvestmentConfigurationScreen` marks portfolio connected/skipped and
    // clears the whole stack down to Home itself once the user finishes; if
    // they instead back out without confirming, they just return here.
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const InvestmentConfigurationScreen()),
    );
  }

  Future<void> _handleSkip() async {
    await DI.onboardingStateRepository.markPortfolioSkipped();
    if (mounted) _goHome();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/images/bg_nebula.png'), fit: BoxFit.cover),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: GlassCard(
                  padding: const EdgeInsets.all(24),
                  borderColor: AppColors.neonCyan.withValues(alpha: 0.4),
                  borderRadius: 28,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(Icons.diamond_outlined, color: AppColors.neonCyan.withValues(alpha: 0.85), size: 40),
                      const SizedBox(height: 16),
                      Text(
                        Translator.translate(AppStrings.portfolioChoiceTitle),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: context.colors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        Translator.translate(AppStrings.portfolioChoiceBody),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: context.colors.textSecondary, fontSize: 14, height: 1.4),
                      ),
                      const SizedBox(height: 24),
                      GameButton(
                        label: Translator.translate(AppStrings.importPortfolioButton),
                        icon: Icons.cloud_download_outlined,
                        colors: const [AppColors.neonViolet, AppColors.neonPink],
                        onPressed: _handleImport,
                      ),
                      const SizedBox(height: 12),
                      GameButton(
                        label: Translator.translate(AppStrings.addManuallyButton),
                        icon: Icons.edit_outlined,
                        colors: const [AppColors.spaceBlue, AppColors.neonCyan],
                        onPressed: _handleAddManually,
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _handleSkip,
                        child: Text(
                          Translator.translate(AppStrings.skipForNowButton),
                          style: TextStyle(color: context.colors.textSecondary, fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (_petName != null && _petName!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          Translator.translate(AppStrings.portfolioChoiceFootnote, params: {'petName': _petName!}),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: context.colors.textSecondary, fontSize: 12, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
