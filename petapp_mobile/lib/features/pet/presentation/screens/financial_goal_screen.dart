import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/game_button.dart';
import 'package:petrimonium/features/onboarding/presentation/screens/tutorial_screen.dart';
import 'package:petrimonium/features/pet/data/models/investment_horizon_enum.dart';
import 'package:petrimonium/features/pet/data/models/pet_goal_enum.dart';
import 'package:petrimonium/features/pet/presentation/widgets/option_picker_sheet.dart';

/// Onboarding's "Choose Your Financial Goal" step — framed as a life
/// objective (per the redesign) rather than a risk/strategy question, so it
/// reads as personal, not a financial form. The selection personalizes
/// future missions/recommendations; nothing here is mandatory data like a
/// portfolio, so there is no skip affordance — picking a goal costs nothing.
class FinancialGoalScreen extends StatefulWidget {
  const FinancialGoalScreen({super.key});

  @override
  State<FinancialGoalScreen> createState() => _FinancialGoalScreenState();
}

class _FinancialGoalScreenState extends State<FinancialGoalScreen> {
  PetGoalEnum _selectedGoal = PetGoalEnum.buildWealth;
  InvestmentHorizonEnum _selectedHorizon = InvestmentHorizonEnum.mediumTerm;
  bool _isSaving = false;

  void _selectGoal(PetGoalEnum goal) {
    HapticFeedback.selectionClick();
    setState(() => _selectedGoal = goal);
  }

  Future<void> _pickHorizon() async {
    HapticFeedback.selectionClick();
    final picked = await showOptionPickerSheet<InvestmentHorizonEnum>(
      context,
      title: Translator.translate(AppStrings.financialGoalTitle),
      options: InvestmentHorizonEnum.values,
      selected: _selectedHorizon,
      labelOf: (h) => h.label,
      descriptionOf: (h) => h.description,
      iconOf: (h) => h.icon,
    );
    if (picked == null || !mounted) return;
    setState(() => _selectedHorizon = picked);
  }

  Future<void> _handleContinue() async {
    setState(() => _isSaving = true);
    try {
      await DI.petPreferencesRepository.saveGoal(_selectedGoal);
      await DI.petPreferencesRepository.saveHorizon(_selectedHorizon);
      await DI.onboardingStateRepository.setGoalChosen();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const TutorialScreen()),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/images/bg_nebula.png'), fit: BoxFit.cover),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Column(
                  children: [
                    Text(
                      Translator.translate(AppStrings.financialGoalTitle),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: context.colors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Translator.translate(AppStrings.financialGoalSubtitle),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: context.colors.textSecondary, fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      for (final goal in PetGoalEnum.values) _buildGoalCard(goal),
                      const SizedBox(height: 8),
                      _buildHorizonRow(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: GameButton(
                  label: Translator.translate(AppStrings.financialGoalContinue),
                  icon: Icons.arrow_forward,
                  iconTrailing: true,
                  isLoading: _isSaving,
                  pulse: true,
                  onPressed: _handleContinue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalCard(PetGoalEnum goal) {
    final isSelected = goal == _selectedGoal;
    final tokens = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectGoal(goal),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.neonCyan.withValues(alpha: 0.14) : tokens.textPrimary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected ? AppColors.neonCyan : tokens.textPrimary.withValues(alpha: 0.12),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (isSelected ? AppColors.neonCyan : tokens.textPrimary).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(goal.icon, color: isSelected ? AppColors.neonCyan : tokens.textSecondary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.label,
                        style: TextStyle(
                          color: tokens.textPrimary,
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(goal.description, style: TextStyle(color: tokens.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                if (isSelected) const Icon(Icons.check_circle, color: AppColors.neonCyan),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHorizonRow() {
    final tokens = context.colors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _pickHorizon,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: tokens.textPrimary.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: tokens.textPrimary.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Icon(Icons.access_time, color: tokens.textTertiary, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(_selectedHorizon.label, style: TextStyle(color: tokens.textSecondary, fontSize: 13)),
              ),
              Icon(Icons.keyboard_arrow_down, color: tokens.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
