import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/widgets/app_loading_indicator.dart';
import 'package:petrimonium/core/widgets/game_button.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/academy/domain/entities/academy_module.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson.dart';
import 'package:petrimonium/features/academy/presentation/controllers/academy_controller.dart';
import 'package:petrimonium/features/academy/presentation/screens/lesson_screen.dart';
import 'package:petrimonium/features/academy/presentation/screens/module_detail_screen.dart';
import 'package:petrimonium/features/academy/presentation/widgets/module_card.dart';
import 'package:petrimonium/features/game/domain/services/level_calculator.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';

/// The "Academia" tab: current level, an unmissable "what's next" CTA, and
/// the module list — the answer to "what should I learn next?" is always on
/// screen (see `docs/ACADEMY_ENGINE.md` §5).
///
/// No own `Scaffold`/`AppBar`/background — like `PortfolioScreen` and
/// `MentorScreen`, this is embedded directly in `DashboardScreen`'s shared
/// `Scaffold`/`AppBar`/`CosmicBackground`/`IndexedStack`. Module detail and
/// individual lessons remain separately pushed screens (they need their own
/// back navigation); only the top-level tab content lives here.
class AcademyHomeScreen extends StatefulWidget {
  const AcademyHomeScreen({super.key, required this.mascotController});

  final MascotController mascotController;

  @override
  State<AcademyHomeScreen> createState() => _AcademyHomeScreenState();
}

class _AcademyHomeScreenState extends State<AcademyHomeScreen> {
  late final AcademyController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AcademyController(repository: DI.academyProgressRepository);
    _controller.addListener(_onChanged);
    _controller.load();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  Route _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.04), end: Offset.zero)
              .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        ),
      ),
      transitionDuration: const Duration(milliseconds: 350),
    );
  }

  Future<void> _openLesson(Lesson lesson) async {
    HapticFeedback.selectionClick();
    await Navigator.of(context).push(
      _fadeRoute(LessonScreen(lesson: lesson, mascotController: widget.mascotController)),
    );
    _controller.load();
  }

  Future<void> _openModule(AcademyModule module) async {
    HapticFeedback.selectionClick();
    await Navigator.of(context).push(
      _fadeRoute(ModuleDetailScreen(module: module, mascotController: widget.mascotController)),
    );
    _controller.load();
  }

  @override
  Widget build(BuildContext context) {
    // Rebuilds when the user switches language in Settings — curriculum
    // content (AcademyCatalog) and this screen's chrome both key off
    // `Translator.currentLanguage`, which only changes there.
    return ValueListenableBuilder<String>(
      valueListenable: Translator.languageNotifier,
      builder: (context, _, __) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final tokens = context.colors;
    final level = LevelCalculator.fromXp(widget.mascotController.profile.xp);

    if (_controller.isLoading) {
      return const AppLoadingIndicator();
    }

    return RefreshIndicator(
      color: tokens.primary,
      backgroundColor: tokens.surfaceElevated,
      onRefresh: _controller.load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLevelHeader(context, level.level),
            const SizedBox(height: 20),
            if (_controller.nextLesson != null) ...[
              _buildContinueCard(context, _controller.nextLesson!),
              const SizedBox(height: 24),
            ],
            Text(
              Translator.translate(AppStrings.academyModulesSectionLabel),
              style: TextStyle(color: tokens.primary.withValues(alpha: 0.6), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2),
            ),
            const SizedBox(height: 10),
            for (final module in _controller.modules) ...[
              ModuleCard(
                module: module,
                status: _controller.statusFor(module),
                completedLessons: _controller.completedLessonCountFor(module),
                onTap: () => _openModule(module),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelHeader(BuildContext context, int level) {
    final tokens = context.colors;
    return GlassCard(
      borderColor: AppColors.neonCyan.withValues(alpha: 0.3),
      borderRadius: 20,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neonCyan.withValues(alpha: 0.15),
                border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.5), width: 1.5),
              ),
              child: const Icon(Icons.school_outlined, color: AppColors.neonCyan, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Translator.translate(AppStrings.academyLevelLabel, params: {'level': '$level'}),
                    style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Translator.translate(
                      AppStrings.academyXpEarnedLabel,
                      params: {'xp': '${_controller.totalXpEarned}'},
                    ),
                    style: TextStyle(color: tokens.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueCard(BuildContext context, Lesson lesson) {
    final tokens = context.colors;
    return GlassCard(
      borderColor: AppColors.goldenBorder.withValues(alpha: 0.4),
      borderRadius: 20,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Translator.translate(AppStrings.academyContinueSectionLabel),
              style: TextStyle(color: AppColors.goldenBorder, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2),
            ),
            const SizedBox(height: 6),
            Text(lesson.title, style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.bold, fontSize: 17)),
            const SizedBox(height: 4),
            Text(
              Translator.translate(AppStrings.academyXpToCompleteLabel, params: {'xp': '${lesson.xpReward}'}),
              style: TextStyle(color: tokens.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 14),
            GameButton(
              label: Translator.translate(AppStrings.academyStartLessonButton),
              icon: Icons.play_arrow_rounded,
              colors: const [AppColors.neonViolet, AppColors.neonPink],
              pulse: true,
              onPressed: () => _openLesson(lesson),
            ),
          ],
        ),
      ),
    );
  }
}
