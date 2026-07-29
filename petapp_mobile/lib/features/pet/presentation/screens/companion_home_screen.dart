import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petapp_mobile/core/constants/app_colors.dart';
import 'package:petapp_mobile/core/constants/app_strings.dart';
import 'package:petapp_mobile/core/di/dependency_injection.dart';
import 'package:petapp_mobile/core/utils/game_snack.dart';
import 'package:petapp_mobile/core/utils/translator.dart';
import 'package:petapp_mobile/core/widgets/glass_card.dart';
import 'package:petapp_mobile/features/pet/data/models/pet_specie_enum.dart';
import 'package:petapp_mobile/features/pet/domain/entities/companion_personality.dart';
import 'package:petapp_mobile/features/pet/domain/entities/pet_accessory.dart';
import 'package:petapp_mobile/features/pet/domain/enums/accessory_type.dart';
import 'package:petapp_mobile/features/pet/domain/enums/character_emotion.dart';
import 'package:petapp_mobile/features/pet/domain/enums/idle_variant.dart';
import 'package:petapp_mobile/features/pet/domain/enums/pet_accessory_id.dart';
import 'package:petapp_mobile/features/pet/domain/enums/pet_animation_state.dart';
import 'package:petapp_mobile/features/pet/domain/services/companion_progress.dart';
import 'package:petapp_mobile/features/pet/presentation/character/character_engine.dart';
import 'package:petapp_mobile/features/pet/presentation/character/widgets/character_widget.dart';
import 'package:petapp_mobile/features/pet/presentation/screens/financial_goal_screen.dart';
import 'package:petapp_mobile/features/pet/presentation/widgets/option_picker_sheet.dart';
import 'package:petapp_mobile/features/portfolio/domain/entities/achievement.dart';

/// The companion's home — what used to be "Pet Profile" (a stat sheet with a
/// radar chart, Regeneration/Intelligence/Summoning Cost, and a fake DY/ROE/
/// P/VP/Stock chart) is now a place to *visit* a living financial companion.
/// No RPG attributes, no fake numbers, no notion of one pet being "stronger"
/// than another — only appearance, personality and the real relationship
/// that's grown through play (level, friendship, memories, mood), all
/// derived from data that's actually true (see `CompanionProgress`).
///
/// Two modes, one screen:
///  - First meeting (`profile.name` unset): the onboarding step — greet the
///    player, let them pick a species and a name for their companion.
///  - Revisit (name already set): the actual "home" — living environment,
///    companion info, personality, friendship, mood, memories, daily quote,
///    evolution and accessories.
class CompanionHomeScreen extends StatefulWidget {
  const CompanionHomeScreen({
    super.key,
    this.externalEngine,
    this.achievements = const [],
  });

  /// Reuses an already-loaded engine (e.g. the Dashboard's) instead of
  /// creating and loading a new one — avoids a duplicate profile fetch and
  /// keeps a single live source of truth for the mascot's state.
  final CharacterEngine? externalEngine;

  /// Unlocked-permanent achievements, used to populate the Memories and
  /// Recent Activity sections with real milestones. Empty during onboarding
  /// (no portfolio history exists yet) — both sections degrade to a
  /// warm empty state rather than showing fabricated numbers.
  final List<Achievement> achievements;

  @override
  State<CompanionHomeScreen> createState() => _CompanionHomeScreenState();
}

class _CompanionHomeScreenState extends State<CompanionHomeScreen> {
  static const _nameSuggestions = [
    'Atlas',
    'Bolt',
    'Loki',
    'Charlie',
    'Max',
    'Nino',
  ];

  static const Map<PetSpecieEnum, IconData> _specieIcons = {
    PetSpecieEnum.CAT: Icons.cruelty_free,
    PetSpecieEnum.DOG: Icons.pets,
    PetSpecieEnum.FOX: Icons.local_fire_department,
    PetSpecieEnum.WOLF: Icons.nightlight_round,
    PetSpecieEnum.BEAR: Icons.catching_pokemon,
    PetSpecieEnum.LION: Icons.star,
  };

  static const Map<PetAccessoryId, IconData> _accessoryIcons = {
    PetAccessoryId.baseballCap: Icons.sports_baseball,
    PetAccessoryId.wizardHat: Icons.auto_fix_high,
    PetAccessoryId.spaceHelmet: Icons.rocket_launch,
    PetAccessoryId.goldenCrown: Icons.workspace_premium,
    PetAccessoryId.smartGlasses: Icons.visibility,
    PetAccessoryId.sunglasses: Icons.wb_sunny,
    PetAccessoryId.bowTie: Icons.checkroom,
    PetAccessoryId.scarf: Icons.checkroom,
    PetAccessoryId.headphones: Icons.headphones,
    PetAccessoryId.backpack: Icons.backpack,
    PetAccessoryId.angelWings: Icons.auto_awesome,
    PetAccessoryId.heroCape: Icons.shield,
  };

  late final CharacterEngine _engine;
  late final bool _ownsEngine;
  bool _isSaving = false;
  bool _showNameError = false;
  final _nameController = TextEditingController();

  bool get _isFirstMeeting => (_engine.profile.name ?? '').trim().isEmpty;

  @override
  void initState() {
    super.initState();
    final external = widget.externalEngine;
    if (external != null) {
      _engine = external;
      _ownsEngine = false;
    } else {
      _engine = CharacterEngine(
        mascotRepository: DI.mascotRepository,
        petRepository: DI.petRepository,
      );
      _ownsEngine = true;
      _engine.loadProfile();
    }
    _engine.addListener(_onEngineChanged);
  }

  void _onEngineChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _engine.removeListener(_onEngineChanged);
    if (_ownsEngine) _engine.dispose();
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

  void _selectSpecie(PetSpecieEnum specie) {
    HapticFeedback.selectionClick();
    _engine.mascot.updateSpecie(specie);
  }

  Future<void> _handleConfirmFirstMeeting() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _showNameError = true);
      return;
    }

    setState(() => _isSaving = true);
    try {
      await DI.petRepository.configurePet(_engine.profile.specie);
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
          '${Translator.translate(AppStrings.failedToSavePet)}: $e',
          isError: true,
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
      appBar: AppBar(
        title: Text(
          Translator.translate(AppStrings.companionHomeTitle),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 800;
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 4, child: _buildLeftPanel()),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 6,
                        child: SingleChildScrollView(child: _buildRightPanel()),
                      ),
                    ],
                  );
                }
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildLeftPanel(),
                      const SizedBox(height: 16),
                      _buildRightPanel(),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ── Left panel ───────────────────────────────────────────────────────────

  Widget _buildLeftPanel() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 10,
          spreadRadius: 2,
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _isFirstMeeting
            ? _firstMeetingLeftContent()
            : _returningLeftContent(),
      ),
    );
  }

  List<Widget> _firstMeetingLeftContent() {
    return [
      Text(
        Translator.translate(AppStrings.meetPetGreeting),
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        Translator.translate(AppStrings.meetPetIntro),
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.subtleText,
          fontSize: 13,
          height: 1.4,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        Translator.translate(AppStrings.meetPetNeedName),
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.goldenBorder,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 16),
      _buildCharacterStage(size: 220),
      const SizedBox(height: 16),
      Text(
        Translator.translate(AppStrings.meetPetSpeciesPrompt),
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white70, fontSize: 13),
      ),
      const SizedBox(height: 12),
      _buildPetSelector(),
      const SizedBox(height: 20),
      _buildNameField(),
      const SizedBox(height: 20),
      _buildConfirmButton(),
    ];
  }

  List<Widget> _returningLeftContent() {
    final profile = _engine.profile;
    return [
      _buildCharacterStage(size: 240),
      const SizedBox(height: 16),
      Text(
        profile.name ?? '',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 6),
      Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.neonCyan.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.neonCyan.withValues(alpha: 0.4),
            ),
          ),
          child: Text(
            _speciesLabel(profile.specie),
            style: const TextStyle(
              color: AppColors.neonCyan,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      const SizedBox(height: 20),
      Center(
        child: Text(
          Translator.translate(AppStrings.manageInSettingsHint),
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.subtleText, fontSize: 12),
        ),
      ),
    ];
  }

  /// The living character — an aura-lit stage around `CharacterWidget`, which
  /// is always animating (breathing, blinking, idle micro-motion) and reacts
  /// to tap/double-tap/long-press/drag on its own. Replaces the old static
  /// `Image.asset` + hand-rolled breathe/float tweens.
  Widget _buildCharacterStage({required double size}) {
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.neonCyan.withValues(alpha: 0.18),
              AppColors.spaceDark.withValues(alpha: 0.05),
            ],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        padding: const EdgeInsets.all(12),
        child: Center(
          child: CharacterWidget(controller: _engine, size: size - 40),
        ),
      ),
    );
  }

  Widget _buildPetSelector() {
    final selected = _engine.profile.specie;
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: PetSpecieEnum.values.length,
        itemBuilder: (context, index) {
          final specie = PetSpecieEnum.values[index];
          final isSelected = selected == specie;
          return GestureDetector(
            onTap: () => _selectSpecie(specie),
            child: Container(
              width: 70,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.neonCyan.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppColors.neonCyan
                      : Colors.white.withValues(alpha: 0.2),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _specieIcons[specie] ?? Icons.pets,
                    color: isSelected ? AppColors.neonCyan : Colors.white70,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _speciesLabel(specie),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
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

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          Translator.translate(AppStrings.namePetPrompt),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
          onChanged: (_) {
            if (_showNameError) setState(() => _showNameError = false);
          },
          decoration: InputDecoration(
            hintText: Translator.translate(AppStrings.namePetHint),
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: AppColors.spaceDark.withValues(alpha: 0.5),
            errorText: _showNameError
                ? Translator.translate(AppStrings.namePetRequiredError)
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AppColors.neonCyan.withValues(alpha: 0.4),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AppColors.neonCyan.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.neonCyan,
                width: 1.5,
              ),
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
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: Colors.white.withValues(alpha: 0.06),
              selectedColor: AppColors.neonCyan.withValues(alpha: 0.25),
              side: BorderSide(
                color: isSelected
                    ? AppColors.neonCyan
                    : Colors.white.withValues(alpha: 0.15),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
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
          onTap: _isSaving ? null : _handleConfirmFirstMeeting,
          child: Center(
            child: _isSaving
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    Translator.translate(AppStrings.meetPetContinue),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // ── Right panel — the companion's living home ───────────────────────────

  Widget _buildRightPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLivingRoomCard(),
        const SizedBox(height: 16),
        _buildCompanionInfoCard(),
        const SizedBox(height: 16),
        _buildPersonalityCard(),
        const SizedBox(height: 16),
        _buildFriendshipCard(),
        const SizedBox(height: 16),
        _buildMoodCard(),
        const SizedBox(height: 16),
        _buildDailyQuoteCard(),
        const SizedBox(height: 16),
        _buildMemoriesCard(),
        const SizedBox(height: 16),
        _buildRecentActivityCard(),
        const SizedBox(height: 16),
        _buildEvolutionLadderCard(),
        const SizedBox(height: 16),
        _buildAccessoriesCard(),
      ],
    );
  }

  Widget _sectionCard({
    required String title,
    required Widget child,
    IconData? icon,
  }) {
    return GlassCard(
      borderColor: AppColors.neonCyan.withValues(alpha: 0.25),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppColors.neonCyan, size: 18),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  /// The companion's ambient home: a soft, particle-lit backdrop plus
  /// whatever it's actually doing right now — sourced directly from
  /// `IdleBehaviorController.variant`/the sleep state, never invented.
  Widget _buildLivingRoomCard() {
    final petName = _engine.profile.name;
    final displayName = (petName == null || petName.isEmpty)
        ? _speciesLabel(_engine.profile.specie)
        : petName;
    final title = Translator.translate(
      AppStrings.companionRoomTitle,
      params: {'petName': displayName},
    );
    final activity = _currentActivity();

    return GlassCard(
      borderColor: AppColors.neonViolet.withValues(alpha: 0.3),
      boxShadow: [
        BoxShadow(
          color: AppColors.neonViolet.withValues(alpha: 0.12),
          blurRadius: 18,
          spreadRadius: 2,
        ),
      ],
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.neonViolet.withValues(alpha: 0.10),
              AppColors.spaceDark.withValues(alpha: 0.0),
              AppColors.neonCyan.withValues(alpha: 0.08),
            ],
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -10,
              right: -10,
              child: _particle(46, AppColors.neonPink.withValues(alpha: 0.18)),
            ),
            Positioned(
              bottom: -16,
              left: -16,
              child: _particle(64, AppColors.neonCyan.withValues(alpha: 0.14)),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Row(
                      key: ValueKey(activity.$2),
                      children: [
                        Text(activity.$1, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            activity.$2,
                            style: const TextStyle(
                              color: AppColors.subtleText,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _particle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: size)],
      ),
    );
  }

  /// (emoji, label) for what the companion is doing right now — real engine
  /// state, not a fabricated activity feed.
  (String, String) _currentActivity() {
    if (_engine.animationState == PetAnimationState.sleep) {
      return ('😴', Translator.translate(AppStrings.activitySleeping));
    }
    switch (_engine.idle.variant) {
      case IdleVariant.breathing:
        return ('😌', Translator.translate(AppStrings.activityRelaxing));
      case IdleVariant.blinking:
        return ('👀', Translator.translate(AppStrings.activityWatching));
      case IdleVariant.stretch:
        return ('🙆', Translator.translate(AppStrings.activityStretching));
      case IdleVariant.sit:
        return ('🧘', Translator.translate(AppStrings.activitySitting));
      case IdleVariant.layDown:
        return ('💤', Translator.translate(AppStrings.activityResting));
      case IdleVariant.lookUp:
        return ('✨', Translator.translate(AppStrings.activityLookingUp));
      case IdleVariant.lookDown:
        return ('👁️', Translator.translate(AppStrings.activityLookingAround));
      case IdleVariant.think:
        return ('🤔', Translator.translate(AppStrings.activityThinkingMarket));
      case IdleVariant.wave:
        return ('👋', Translator.translate(AppStrings.activityWaving));
      case IdleVariant.eat:
        return ('🍪', Translator.translate(AppStrings.activitySnack));
      case IdleVariant.drink:
        return ('🥤', Translator.translate(AppStrings.activitySip));
      case IdleVariant.dance:
        return ('💃', Translator.translate(AppStrings.activityDancing));
    }
  }

  Widget _buildCompanionInfoCard() {
    final profile = _engine.profile;
    final level = CompanionProgress.levelFor(profile.xp);
    final bucket = profile.stage.bucket;
    final since = profile.companionSince;

    return _sectionCard(
      title: Translator.translate(AppStrings.companionSectionTitle),
      icon: Icons.pets,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(
            Translator.translate(AppStrings.speciesLabel),
            _speciesLabel(profile.specie),
          ),
          _infoRow(
            Translator.translate(AppStrings.companionSinceLabel),
            since == null
                ? Translator.translate(AppStrings.todayLabel)
                : _formatDate(since),
          ),
          _infoRow(
            Translator.translate(AppStrings.currentEvolutionLabel),
            _evolutionBucketLabel(bucket),
          ),
          const SizedBox(height: 8),
          Text(
            Translator.translate(
              AppStrings.levelDisplay,
              params: {'level': '${level.level}'},
            ),
            style: const TextStyle(
              color: AppColors.goldenBorder,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Container(
                  height: 10,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: level.progress),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => FractionallySizedBox(
                    widthFactor: value.clamp(0.0, 1.0),
                    child: Container(
                      height: 10,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.neonCyan, AppColors.goldenBorder],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${level.xpIntoLevel} / ${level.xpForNextLevel} XP',
            style: const TextStyle(color: AppColors.subtleText, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.subtleText, fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalityCard() {
    final traits =
        companionPersonalityBySpecies[_engine.profile.specie] ?? const [];
    return _sectionCard(
      title: Translator.translate(AppStrings.personalityTitle),
      icon: Icons.auto_awesome,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: traits.map((trait) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.neonPurple.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.neonPurple.withValues(alpha: 0.35),
              ),
            ),
            child: Text(
              _traitLabel(trait),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFriendshipCard() {
    final profile = _engine.profile;
    final days = CompanionProgress.daysTogether(
      companionSince: profile.companionSince,
    );
    final score = CompanionProgress.friendshipScore(
      companionSince: profile.companionSince,
      xp: profile.xp,
    );
    final tier = CompanionProgress.friendshipTierFor(score);
    final unlockedMilestones = widget.achievements
        .where((a) => a.unlocked)
        .length;

    return _sectionCard(
      title: Translator.translate(AppStrings.friendshipTitle),
      icon: Icons.favorite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _friendshipTierLabel(tier),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '$score%',
                style: const TextStyle(
                  color: AppColors.neonPink,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Container(
                  height: 8,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: score / 100),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => FractionallySizedBox(
                    widthFactor: value.clamp(0.0, 1.0),
                    child: Container(height: 8, color: AppColors.neonPink),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _statTile(
                  Icons.calendar_today,
                  Translator.translate(AppStrings.daysTogetherLabel),
                  '$days',
                ),
              ),
              if (widget.achievements.isNotEmpty)
                Expanded(
                  child: _statTile(
                    Icons.emoji_events,
                    Translator.translate(AppStrings.sharedMilestonesLabel),
                    '$unlockedMilestones',
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statTile(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppColors.neonCyan, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.subtleText, fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMoodCard() {
    final emotion = _engine.emotion.emotion;
    return _sectionCard(
      title: Translator.translate(AppStrings.moodTitle),
      icon: Icons.sentiment_satisfied_alt,
      child: Row(
        children: [
          Text(_moodEmoji(emotion), style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              _moodReason(),
              style: const TextStyle(
                color: AppColors.subtleText,
                fontSize: 13,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyQuoteCard() {
    final quote = _dailyQuote();
    final signature = (_engine.profile.name ?? '').isEmpty
        ? ''
        : '— ${_engine.profile.name}';
    return _sectionCard(
      title: Translator.translate(AppStrings.dailyQuoteTitle),
      icon: Icons.format_quote,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '"$quote"',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
          if (signature.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              signature,
              style: const TextStyle(
                color: AppColors.goldenBorder,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMemoriesCard() {
    final profile = _engine.profile;
    final unlocked =
        widget.achievements
            .where((a) => a.unlocked && a.unlockedAt != null)
            .toList()
          ..sort((a, b) => a.unlockedAt!.compareTo(b.unlockedAt!));

    final entries = <Widget>[
      _timelineEntry(
        Icons.celebration,
        (profile.name ?? '').isEmpty
            ? Translator.translate(AppStrings.memoriesEmptyState)
            : Translator.translate(
                AppStrings.memoriesFirstMeeting,
                params: {'petName': profile.name!},
              ),
        profile.companionSince == null
            ? Translator.translate(AppStrings.todayLabel)
            : _formatDate(profile.companionSince!),
      ),
      for (final a in unlocked.take(4))
        _timelineEntry(a.icon, a.title, _formatDate(a.unlockedAt!)),
    ];

    return _sectionCard(
      title: Translator.translate(AppStrings.memoriesTitle),
      icon: Icons.auto_stories,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: entries,
      ),
    );
  }

  Widget _buildRecentActivityCard() {
    final recent =
        widget.achievements
            .where((a) => a.unlocked && a.unlockedAt != null)
            .toList()
          ..sort((a, b) => b.unlockedAt!.compareTo(a.unlockedAt!));

    return _sectionCard(
      title: Translator.translate(AppStrings.recentActivityTitle),
      icon: Icons.history,
      child: recent.isEmpty
          ? Text(
              Translator.translate(AppStrings.recentActivityEmptyState),
              style: const TextStyle(color: AppColors.subtleText, fontSize: 13),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final a in recent.take(4))
                  _timelineEntry(a.icon, a.title, _relativeDay(a.unlockedAt!)),
              ],
            ),
    );
  }

  Widget _timelineEntry(IconData icon, String title, String when) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.neonCyan, size: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          Text(
            when,
            style: const TextStyle(color: AppColors.subtleText, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildEvolutionLadderCard() {
    final currentBucket = _engine.profile.stage.bucket;
    return _sectionCard(
      title: Translator.translate(AppStrings.evolutionTitle),
      icon: Icons.trending_up,
      child: Row(
        children: [
          for (final bucket in EvolutionBucket.values) ...[
            Expanded(
              child: _evolutionStep(
                bucket,
                isCurrent: bucket == currentBucket,
                isPast: bucket.index < currentBucket.index,
              ),
            ),
            if (bucket != EvolutionBucket.values.last)
              Container(
                width: 16,
                height: 2,
                color: bucket.index < currentBucket.index
                    ? AppColors.neonCyan.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.15),
              ),
          ],
        ],
      ),
    );
  }

  Widget _evolutionStep(
    EvolutionBucket bucket, {
    required bool isCurrent,
    required bool isPast,
  }) {
    final reached = isCurrent || isPast;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isCurrent ? 20 : 14,
          height: isCurrent ? 20 : 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: reached
                ? AppColors.neonCyan
                : Colors.white.withValues(alpha: 0.15),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: AppColors.neonCyan.withValues(alpha: 0.6),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _evolutionBucketLabel(bucket),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: reached ? Colors.white : AppColors.subtleText,
            fontSize: 10,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildAccessoriesCard() {
    final profile = _engine.profile;
    return _sectionCard(
      title: Translator.translate(AppStrings.accessoriesTitle),
      icon: Icons.checkroom,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final slot in AccessoryType.values) ...[
            _accessorySlotRow(
              slot,
              profile.equippedAccessories[slot],
              profile.unlockedAccessories,
            ),
            const SizedBox(height: 10),
          ],
          Text(
            Translator.translate(AppStrings.cosmeticOnlyHint),
            style: const TextStyle(
              color: AppColors.subtleText,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _accessorySlotRow(
    AccessoryType slot,
    PetAccessoryId? equipped,
    Set<PetAccessoryId> unlocked,
  ) {
    final unlockedForSlot = PetAccessoryId.values
        .where((a) => a.slot == slot && unlocked.contains(a))
        .toList();
    final lockedCount =
        PetAccessoryId.values.where((a) => a.slot == slot).length -
        unlockedForSlot.length;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openAccessoryPicker(slot, equipped, unlockedForSlot),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Icon(
                equipped != null
                    ? (_accessoryIcons[equipped] ?? Icons.checkroom)
                    : Icons.remove_circle_outline,
                color: AppColors.neonCyan,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _accessorySlotLabel(slot),
                      style: const TextStyle(
                        color: AppColors.subtleText,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      equipped != null
                          ? _accessoryLabel(equipped)
                          : Translator.translate(AppStrings.accessoryNone),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (lockedCount > 0)
                Text(
                  '+$lockedCount 🔒',
                  style: const TextStyle(
                    color: AppColors.subtleText,
                    fontSize: 11,
                  ),
                ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right,
                color: AppColors.subtleText,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openAccessoryPicker(
    AccessoryType slot,
    PetAccessoryId? equipped,
    List<PetAccessoryId> options,
  ) async {
    final selection = await showOptionPickerSheet<PetAccessoryId?>(
      context,
      title: Translator.translate(AppStrings.accessoryPickerTitle),
      options: [null, ...options],
      selected: equipped,
      labelOf: (id) => id == null
          ? Translator.translate(AppStrings.accessoryNoneOption)
          : _accessoryLabel(id),
      descriptionOf: (_) => Translator.translate(AppStrings.cosmeticOnlyHint),
      iconOf: (id) => id == null
          ? Icons.remove_circle_outline
          : (_accessoryIcons[id] ?? Icons.checkroom),
    );
    if (selection == null) {
      await _engine.unequipAccessory(slot);
    } else {
      await _engine.equipAccessory(PetAccessory(id: selection, unlocked: true));
    }
  }

  // ── Presentation helpers ─────────────────────────────────────────────────

  String _speciesLabel(PetSpecieEnum specie) {
    switch (specie) {
      case PetSpecieEnum.DOG:
        return Translator.translate(AppStrings.speciesDog);
      case PetSpecieEnum.CAT:
        return Translator.translate(AppStrings.speciesCat);
      case PetSpecieEnum.WOLF:
        return Translator.translate(AppStrings.speciesWolf);
      case PetSpecieEnum.FOX:
        return Translator.translate(AppStrings.speciesFox);
      case PetSpecieEnum.BEAR:
        return Translator.translate(AppStrings.speciesBear);
      case PetSpecieEnum.LION:
        return Translator.translate(AppStrings.speciesLion);
    }
  }

  String _traitLabel(PersonalityTrait trait) {
    switch (trait) {
      case PersonalityTrait.optimistic:
        return Translator.translate(AppStrings.traitOptimistic);
      case PersonalityTrait.patient:
        return Translator.translate(AppStrings.traitPatient);
      case PersonalityTrait.curious:
        return Translator.translate(AppStrings.traitCurious);
      case PersonalityTrait.disciplined:
        return Translator.translate(AppStrings.traitDisciplined);
      case PersonalityTrait.friendly:
        return Translator.translate(AppStrings.traitFriendly);
      case PersonalityTrait.protective:
        return Translator.translate(AppStrings.traitProtective);
      case PersonalityTrait.playful:
        return Translator.translate(AppStrings.traitPlayful);
      case PersonalityTrait.confident:
        return Translator.translate(AppStrings.traitConfident);
      case PersonalityTrait.calm:
        return Translator.translate(AppStrings.traitCalm);
    }
  }

  String _friendshipTierLabel(FriendshipTier tier) {
    switch (tier) {
      case FriendshipTier.newFriends:
        return Translator.translate(AppStrings.friendshipTierNew);
      case FriendshipTier.growingCloser:
        return Translator.translate(AppStrings.friendshipTierGrowing);
      case FriendshipTier.greatFriends:
        return Translator.translate(AppStrings.friendshipTierGreat);
      case FriendshipTier.bestFriends:
        return Translator.translate(AppStrings.friendshipTierBest);
    }
  }

  String _evolutionBucketLabel(EvolutionBucket bucket) {
    switch (bucket) {
      case EvolutionBucket.baby:
        return Translator.translate(AppStrings.evolutionBabyLabel);
      case EvolutionBucket.young:
        return Translator.translate(AppStrings.evolutionYoungLabel);
      case EvolutionBucket.adult:
        return Translator.translate(AppStrings.evolutionAdultLabel);
      case EvolutionBucket.master:
        return Translator.translate(AppStrings.evolutionMasterLabel);
      case EvolutionBucket.legendary:
        return Translator.translate(AppStrings.evolutionLegendaryLabel);
    }
  }

  String _accessorySlotLabel(AccessoryType slot) {
    switch (slot) {
      case AccessoryType.headwear:
        return Translator.translate(AppStrings.accessorySlotHeadwear);
      case AccessoryType.eyewear:
        return Translator.translate(AppStrings.accessorySlotEyewear);
      case AccessoryType.neckBack:
        return Translator.translate(AppStrings.accessorySlotNeckBack);
    }
  }

  /// Cosmetic item names aren't translated per-language copy (kept as tidy
  /// title-cased identifiers, same treatment the old screen gave species
  /// names) — there's no gameplay meaning to localize, just a label.
  String _accessoryLabel(PetAccessoryId id) {
    final withSpaces = id.name.replaceAllMapped(
      RegExp('(?<=[a-z])(?=[A-Z])'),
      (m) => ' ',
    );
    return withSpaces[0].toUpperCase() + withSpaces.substring(1);
  }

  String _moodEmoji(CharacterEmotion emotion) {
    switch (emotion) {
      case CharacterEmotion.happy:
      case CharacterEmotion.veryHappy:
      case CharacterEmotion.laughing:
      case CharacterEmotion.love:
      case CharacterEmotion.playful:
        return '😊';
      case CharacterEmotion.proud:
      case CharacterEmotion.confident:
      case CharacterEmotion.determined:
      case CharacterEmotion.motivated:
        return '💪';
      case CharacterEmotion.curious:
      case CharacterEmotion.thinking:
      case CharacterEmotion.confused:
      case CharacterEmotion.surprised:
        return '🤔';
      case CharacterEmotion.excited:
        return '🤩';
      case CharacterEmotion.sad:
      case CharacterEmotion.crying:
      case CharacterEmotion.embarrassed:
      case CharacterEmotion.scared:
      case CharacterEmotion.sick:
      case CharacterEmotion.angry:
      case CharacterEmotion.shocked:
      case CharacterEmotion.dizzy:
        return '😔';
      case CharacterEmotion.sleepy:
      case CharacterEmotion.sleeping:
        return '😴';
      case CharacterEmotion.neutral:
        return '🙂';
    }
  }

  /// A short, *honest* reason for the current mood — tied to real engine
  /// state (animation/emotion), never a specific unproven cause (e.g. never
  /// claims "you received dividends today" unless that's provably why the
  /// mood changed, which the Emotion Controller doesn't currently tag).
  String _moodReason() {
    if (_engine.animationState == PetAnimationState.sleep) {
      final hoursSinceActive = DateTime.now()
          .difference(_engine.profile.lastActiveAt)
          .inHours;
      return Translator.translate(
        hoursSinceActive >= 24
            ? AppStrings.moodReasonSleepingAway
            : AppStrings.moodReasonSleepingLate,
      );
    }
    switch (_engine.emotion.emotion) {
      case CharacterEmotion.proud:
        return Translator.translate(AppStrings.moodReasonProud);
      case CharacterEmotion.veryHappy:
      case CharacterEmotion.love:
      case CharacterEmotion.excited:
        return Translator.translate(AppStrings.moodReasonExcited);
      case CharacterEmotion.curious:
      case CharacterEmotion.thinking:
        return Translator.translate(AppStrings.moodReasonThinking);
      case CharacterEmotion.sad:
      case CharacterEmotion.crying:
        return Translator.translate(AppStrings.moodReasonSteady);
      default:
        return Translator.translate(AppStrings.moodReasonHappy);
    }
  }

  static const List<String> _dailyQuoteKeys = [
    AppStrings.dailyQuote1,
    AppStrings.dailyQuote2,
    AppStrings.dailyQuote3,
    AppStrings.dailyQuote4,
    AppStrings.dailyQuote5,
    AppStrings.dailyQuote6,
    AppStrings.dailyQuote7,
    AppStrings.dailyQuote8,
  ];

  /// Deterministic per-day pick — stable across rebuilds and app restarts
  /// within the same day, rotating to the next quote tomorrow.
  String _dailyQuote() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year)).inDays;
    final key = _dailyQuoteKeys[dayOfYear % _dailyQuoteKeys.length];
    return Translator.translate(key);
  }

  String _relativeDay(DateTime date) {
    final now = DateTime.now();
    final days = DateTime(
      now.year,
      now.month,
      now.day,
    ).difference(DateTime(date.year, date.month, date.day)).inDays;
    if (days <= 0) return Translator.translate(AppStrings.relativeDayToday);
    if (days == 1) return Translator.translate(AppStrings.relativeDayYesterday);
    return Translator.translate(
      AppStrings.relativeDaysAgo,
      params: {'days': '$days'},
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
