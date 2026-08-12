import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/utils/friendly_error_message.dart';
import 'package:petrimonium/core/utils/game_snack.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/pet_assets.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/pet/data/models/pet_specie_enum.dart';
import 'package:petrimonium/features/pet/presentation/screens/financial_goal_screen.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';

/// Onboarding's "Configure Your Pet" step — the pet introduces itself, and
/// the player picks its species and name together in one screen right
/// after registering, before anything financial is asked. The financial
/// goal (`FinancialGoalScreen`) is a separate step later in the flow.
class PetConfigurationScreen extends StatefulWidget {
  const PetConfigurationScreen({super.key});

  @override
  State<PetConfigurationScreen> createState() => _PetConfigurationScreenState();
}

class _PetConfigurationScreenState extends State<PetConfigurationScreen> with SingleTickerProviderStateMixin {
  static const _nameSuggestions = ['Atlas', 'Bolt', 'Loki', 'Charlie', 'Max', 'Nino'];

  PetSpecieEnum _selectedSpecie = PetSpecieEnum.DOG;
  bool _isLoading = false;
  bool _showNameError = false;
  final _nameController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _breatheAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _breatheAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _floatAnimation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _pickSuggestion(String name) {
    HapticFeedback.selectionClick();
    setState(() {
      _nameController.text = name;
      _showNameError = false;
    });
  }

  Future<void> _handleSelectType() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _showNameError = true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await DI.petRepository.configurePet(_selectedSpecie);
      await DI.mascotRepository.saveName(name);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const FinancialGoalScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        GameSnack.show(
          context,
          '${Translator.translate(AppStrings.failedToSavePet)}: ${friendlyErrorMessage(e)}',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(Translator.translate(AppStrings.meetPetTitle), style: TextStyle(color: context.colors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg_nebula.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 800;
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 4, child: _buildLeftPanel()),
                      const SizedBox(width: 16),
                      Expanded(flex: 6, child: _buildRightPanel()),
                    ],
                  );
                } else {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildLeftPanel(),
                        const SizedBox(height: 16),
                        _buildRightPanel(),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeftPanel() {
    final tokens = context.colors;
    return GlassCard(
      padding: const EdgeInsets.all(20),
      boxShadow: [
        BoxShadow(
          color: tokens.shadow,
          blurRadius: 10,
          spreadRadius: 2,
        )
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            Translator.translate(AppStrings.meetPetGreeting),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Translator.translate(AppStrings.meetPetIntro),
            textAlign: TextAlign.center,
            style: TextStyle(color: tokens.textSecondary, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 6),
          Text(
            Translator.translate(AppStrings.meetPetNeedName),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.goldenBorder, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildActivePetCapsule(),
          ),
          const SizedBox(height: 16),
          Text(
            Translator.translate(AppStrings.meetPetSpeciesPrompt),
            textAlign: TextAlign.center,
            style: TextStyle(color: tokens.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 12),
          _buildPetSelector(),
          const SizedBox(height: 20),
          _buildNameField(),
          const SizedBox(height: 20),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    final tokens = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          Translator.translate(AppStrings.namePetPrompt),
          textAlign: TextAlign.center,
          style: TextStyle(color: tokens.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          textAlign: TextAlign.center,
          style: TextStyle(color: tokens.textPrimary),
          onChanged: (_) {
            if (_showNameError) setState(() => _showNameError = false);
          },
          decoration: InputDecoration(
            hintText: Translator.translate(AppStrings.namePetHint),
            hintStyle: TextStyle(color: tokens.textTertiary),
            filled: true,
            fillColor: tokens.surface.withValues(alpha: context.isDarkMode ? 0.5 : 0.94),
            errorText: _showNameError ? Translator.translate(AppStrings.namePetRequiredError) : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.4)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.neonCyan, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: _nameSuggestions.map((name) {
            final isSelected = _nameController.text == name;
            return ChoiceChip(
              label: Text(name),
              selected: isSelected,
              onSelected: (_) => _pickSuggestion(name),
              labelStyle: TextStyle(
                color: isSelected ? tokens.textPrimary : tokens.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: tokens.textPrimary.withValues(alpha: 0.06),
              selectedColor: AppColors.neonCyan.withValues(alpha: 0.25),
              side: BorderSide(color: isSelected ? AppColors.neonCyan : tokens.textPrimary.withValues(alpha: 0.15)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActivePetCapsule() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Transform.scale(
            scale: _breatheAnimation.value,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.neonCyan.withValues(alpha: 0.18),
                    AppColors.spaceDark.withValues(alpha: 0.05),
                  ],
                ),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonCyan.withValues(alpha: 0.15 + (_animationController.value * 0.1)),
                    blurRadius: 40 + (_animationController.value * 15),
                    spreadRadius: 10 + (_animationController.value * 5),
                  ),
                  BoxShadow(
                    color: AppColors.neonPink.withValues(alpha: 0.1 * _animationController.value),
                    blurRadius: 20 * _animationController.value,
                    spreadRadius: 5 * _animationController.value,
                  )
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Image.asset(
                PetAssets.imageFor(_selectedSpecie.name),
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPetSelector() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: PetSpecieEnum.values.length,
        itemBuilder: (context, index) {
          final specie = PetSpecieEnum.values[index];
          final isSelected = _selectedSpecie == specie;
          final tokens = context.colors;
          return GestureDetector(
            onTap: () => setState(() => _selectedSpecie = specie),
            child: Container(
              width: 70,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.neonCyan.withValues(alpha: 0.2) : tokens.textPrimary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.neonCyan : tokens.textPrimary.withValues(alpha: 0.2),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage(PetAssets.imageFor(specie.name)),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(color: tokens.border, width: 1),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    specie.name[0].toUpperCase() + specie.name.substring(1).toLowerCase(),
                    style: TextStyle(
                      color: isSelected ? tokens.textPrimary : tokens.textSecondary,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.neonPurple, AppColors.neonCyan],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: _isLoading ? null : _handleSelectType,
          child: Center(
            child: _isLoading
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(
                    Translator.translate(AppStrings.meetPetContinue),
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }

  /// What the companion actually is: a description of the relationship
  /// ahead, not a stat sheet. No numbers are invented here — the pet has no
  /// financial metrics of its own; those belong to the user's portfolio.
  Widget _buildRightPanel() {
    return GlassCard(
      borderColor: AppColors.neonCyan.withValues(alpha: 0.3),
      boxShadow: [
        BoxShadow(
          color: AppColors.neonCyan.withValues(alpha: 0.1),
          blurRadius: 15,
          spreadRadius: 2,
        )
      ],
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              Translator.translate(AppStrings.meetPetPreviewTitle),
              style: TextStyle(color: context.colors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildPreviewRow(Icons.celebration, AppColors.goldenBorder, Translator.translate(AppStrings.meetPetPreviewCelebrate)),
            const SizedBox(height: 16),
            _buildPreviewRow(Icons.school, AppColors.neonCyan, Translator.translate(AppStrings.meetPetPreviewLearn)),
            const SizedBox(height: 16),
            _buildPreviewRow(Icons.favorite, AppColors.neonPink, Translator.translate(AppStrings.meetPetPreviewRemember)),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewRow(IconData icon, Color color, String label) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(label, style: TextStyle(color: context.colors.textSecondary, fontSize: 14, height: 1.3)),
          ),
        ),
      ],
    );
  }
}
