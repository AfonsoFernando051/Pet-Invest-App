import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_color_tokens.dart';
import '../../../../core/utils/pet_assets.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/di/dependency_injection.dart';

class PetShowcase extends StatefulWidget {
  const PetShowcase({super.key, required this.performancePercent});

  /// Real portfolio total-gain percent (`PortfolioSummary.totalGainPercent`),
  /// used only to color the aura — never displayed as an invented pet stat.
  final double performancePercent;

  @override
  State<PetShowcase> createState() => _PetShowcaseState();
}

class _PetShowcaseState extends State<PetShowcase> with TickerProviderStateMixin {
  // Data
  bool _isLoadingPet = true;
  String _petAsset = PetAssets.imageFor(null);

  // Pet stat value (0.0 – 1.0), sourced from the backend `health` field —
  // see `_fetchMyPet`. There is no real "Mood" figure to show yet (that
  // belongs to the future Character Engine's emotion system), so this is
  // the only stat bar rendered.
  double _health = 0.75;

  // Animation controllers
  late AnimationController _breatheController;
  late AnimationController _floatController;
  late AnimationController _glowController;
  late AnimationController _feedController;
  late AnimationController _cardFloatController;
  late AnimationController _personalityController;

  // Animations
  late Animation<double> _breatheAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _feedAnimation;
  late Animation<double> _cardFloatAnimation;
  late Animation<double> _personalityAnimation;

  // Accelerometer
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  final ValueNotifier<Offset> _parallax = ValueNotifier(Offset.zero);

  @override
  void initState() {
    super.initState();
    _fetchMyPet();
    _initAnimations();
    _initAccelerometer();
  }

  void _initAnimations() {
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
    _breatheAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOutSine),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -6.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.1, end: 0.5).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _feedController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _feedAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -30).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -30, end: 0).chain(CurveTween(curve: Curves.bounceOut)),
        weight: 50,
      ),
    ]).animate(_feedController);

    // Whole-panel gentle float — a slower, independent cycle from the pet's
    // own breathing/floating so the two layers don't move in lockstep (which
    // would read as fake/robotic rather than dimensional).
    _cardFloatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat(reverse: true);
    _cardFloatAnimation = Tween<double>(begin: -3.0, end: 3.0).animate(
      CurvedAnimation(parent: _cardFloatController, curve: Curves.easeInOutSine),
    );

    // Idle "personality" tilt — a stand-in for blink/tail-wag, which would
    // need rigged or Lottie art per evolution stage that doesn't exist yet
    // (see `assets/mascot/animations/`, currently empty). A slow head-tilt
    // wiggle on a static image still reads as "alive" without new assets.
    _personalityController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4600),
    )..repeat(reverse: true);
    _personalityAnimation = Tween<double>(begin: -0.035, end: 0.035).animate(
      CurvedAnimation(parent: _personalityController, curve: Curves.easeInOutSine),
    );
  }

  void _initAccelerometer() {
    try {
      _accelerometerSubscription =
          accelerometerEventStream().listen((AccelerometerEvent event) {
        // Updates the ValueNotifier directly instead of setState() so only
        // the parallax AnimatedBuilder subtree rebuilds, not the whole
        // blurred GlassCard tree, on every sensor tick.
        _parallax.value = Offset(
          (event.x * -3.0).clamp(-20.0, 20.0),
          (event.y * 3.0).clamp(-20.0, 20.0),
        );
      });
    } catch (e) {
      debugPrint('Accelerometer not available: $e');
    }
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _breatheController.dispose();
    _floatController.dispose();
    _glowController.dispose();
    _feedController.dispose();
    _cardFloatController.dispose();
    _personalityController.dispose();
    _parallax.dispose();
    super.dispose();
  }

  Future<void> _fetchMyPet() async {
    try {
      final petData = await DI.petRepository.getMyPet();
      if (petData != null && mounted) {
        final specie = petData['specie'] as String?;
        // Derive health from API if present
        final rawHealth = petData['health'];
        setState(() {
          _petAsset = PetAssets.imageFor(specie);
          if (rawHealth is num) {
            _health = rawHealth.toDouble().clamp(0.0, 100.0) / 100.0;
          }
          _isLoadingPet = false;
        });
        _triggerAction();
      } else {
        if (mounted) setState(() => _isLoadingPet = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingPet = false);
    }
  }

  void _triggerAction() {
    if (!_feedController.isAnimating) {
      HapticFeedback.lightImpact();
      _feedController.forward(from: 0.0);
    }
  }

  Color get _currentAuraColor {
    if (widget.performancePercent < -10) return context.colors.error;
    if (widget.performancePercent < 0)   return AppColors.neonPurple;
    return AppColors.neonCyan;
  }

  @override
  Widget build(BuildContext context) {
    // The pet is positioned to overflow ~22px past the card's bottom edge
    // (see the `Positioned` below) so it reads as standing in front of the
    // panel rather than sealed inside it. `Stack` doesn't count that
    // overflow toward its own size, so a trailing spacer reserves the room
    // for it — otherwise whatever follows this widget in a `Column` would
    // collide with the pet's feet.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCardAndPet(),
        const SizedBox(height: 22),
      ],
    );
  }

  Widget _buildCardAndPet() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        AnimatedBuilder(
          animation: _cardFloatController,
          builder: (context, child) {
            return Transform.translate(offset: Offset(0, _cardFloatAnimation.value), child: child);
          },
          child: GlassCard(
            backgroundColor:
                context.colors.surface.withValues(alpha: context.isDarkMode ? 0.5 : 0.94),
            borderColor: _currentAuraColor.withValues(alpha: 0.3),
            borderWidth: 1,
            borderRadius: 24,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16),
              child: Column(
                children: [
                  // ── Stat bar with real fill ────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatBar(
                        Icons.favorite_border,
                        [const Color(0xFFFF007F), AppColors.neonViolet],
                        value: _health,
                        label: 'HP',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Backdrop: glow dome + glass energy cylinder ────────────────
                  // (the pet itself renders as a sibling below, slightly
                  // overlapping this card's bottom edge — see the outer
                  // Positioned — instead of being fully trapped inside it.)
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Fixed dark "stage" behind the pet, regardless of app
                      // theme — a light card background would otherwise wash
                      // out the cyan/violet/gold aura glow (brief: magical
                      // effects must stay visible in Light mode).
                      Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.spaceDark.withValues(alpha: 0.85),
                              AppColors.spaceDark.withValues(alpha: 0),
                            ],
                            stops: const [0.35, 1.0],
                          ),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _glowController,
                        builder: (context, child) {
                          return Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _currentAuraColor.withValues(alpha: _glowAnimation.value),
                                  blurRadius: 50 + (_glowAnimation.value * 20),
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      Container(
                        width: 240,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(120),
                            bottom: Radius.circular(30),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(alpha: 0.08),
                              Colors.transparent,
                              _currentAuraColor.withValues(alpha: 0.14),
                            ],
                          ),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Pedestal + pet — a sibling of the card, anchored to poke past
        // its bottom edge so the mascot reads as standing in front of the
        // panel rather than sealed inside it.
        Positioned(
          bottom: -22,
          left: 0,
          right: 0,
          child: GestureDetector(
            onTap: _triggerAction,
            child: SizedBox(
              height: 280,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    bottom: 32,
                    child: Container(
                      width: 260,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.spaceDark,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: _currentAuraColor.withValues(alpha: 0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                        border: Border.all(color: _currentAuraColor.withValues(alpha: 0.5)),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 47,
                    child: AnimatedBuilder(
                      animation: Listenable.merge([
                        _breatheController,
                        _floatController,
                        _feedController,
                        _personalityController,
                        _parallax,
                      ]),
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            _parallax.value.dx,
                            _parallax.value.dy + _floatAnimation.value + _feedAnimation.value,
                          ),
                          child: Transform.rotate(
                            angle: _personalityAnimation.value,
                            child: Transform.scale(
                              scaleY: _breatheAnimation.value,
                              scaleX: 1.0 + (1.0 - _breatheAnimation.value),
                              child: _isLoadingPet
                                  ? const SizedBox(
                                      height: 220,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: AppColors.neonCyan,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    )
                                  : Image.asset(
                                      _petAsset,
                                      height: 220,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.pets,
                                        size: 100,
                                        color: Colors.white70,
                                      ),
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Stat bar that shows actual fill based on [value] (0.0–1.0).
  Widget _buildStatBar(
    IconData icon,
    List<Color> colors, {
    required double value,
    required String label,
  }) {
    const double barWidth = 130;
    const double barHeight = 10;
    final tokens = context.colors;

    return Row(
      children: [
        Icon(icon, color: colors.first, size: 18),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: tokens.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 3),
            Stack(
              children: [
                // Track
                Container(
                  width: barWidth,
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: tokens.textTertiary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(barHeight / 2),
                    border: Border.all(
                      color: AppColors.neonCyan.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                ),
                // Fill
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOut,
                  width: barWidth * value.clamp(0.0, 1.0),
                  height: barHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: colors),
                    borderRadius: BorderRadius.circular(barHeight / 2),
                    boxShadow: [
                      BoxShadow(
                        color: colors.first.withValues(alpha: 0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(width: 6),
        Text(
          '${(value * 100).toInt()}%',
          style: TextStyle(
            color: tokens.textPrimary,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
