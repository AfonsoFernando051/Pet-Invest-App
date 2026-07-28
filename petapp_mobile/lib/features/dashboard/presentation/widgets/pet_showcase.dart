import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/di/dependency_injection.dart';

class PetShowcase extends StatefulWidget {
  const PetShowcase({super.key});

  @override
  State<PetShowcase> createState() => _PetShowcaseState();
}

class _PetShowcaseState extends State<PetShowcase> with TickerProviderStateMixin {
  // Data
  double _currentPerformance = 10.0;
  bool _isLoadingPet = true;
  String _petAsset = 'assets/images/generated_dog.png';

  // Pet stat values (0.0 – 1.0)
  double _health = 0.75;
  double _mood   = 0.60;

  // Animation controllers
  late AnimationController _breatheController;
  late AnimationController _floatController;
  late AnimationController _glowController;
  late AnimationController _feedController;

  // Animations
  late Animation<double> _breatheAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _feedAnimation;

  // Accelerometer
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  double _parallaxX = 0;
  double _parallaxY = 0;

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
  }

  void _initAccelerometer() {
    try {
      _accelerometerSubscription =
          accelerometerEventStream().listen((AccelerometerEvent event) {
        if (mounted) {
          setState(() {
            _parallaxX = (event.x * -3.0).clamp(-20.0, 20.0);
            _parallaxY = (event.y * 3.0).clamp(-20.0, 20.0);
          });
        }
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
    super.dispose();
  }

  Future<void> _fetchMyPet() async {
    try {
      final petData = await DI.petRepository.getMyPet();
      if (petData != null && mounted) {
        final specie = (petData['specie'] as String).toLowerCase();
        // Derive health from API if present
        final rawHealth = petData['health'];
        setState(() {
          _petAsset = 'assets/images/generated_$specie.png';
          if (rawHealth != null) {
            _health = (rawHealth as num).toDouble().clamp(0.0, 100.0) / 100.0;
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
    if (_currentPerformance < -10) return Colors.redAccent;
    if (_currentPerformance < 0)   return AppColors.neonPurple;
    return AppColors.neonCyan;
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      backgroundColor: AppColors.spaceDark.withValues(alpha: 0.4),
      borderColor: _currentAuraColor.withValues(alpha: 0.3),
      borderWidth: 1,
      borderRadius: 24,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16),
        child: Column(
          children: [
            // ── Stat bars with real fill ───────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatBar(
                      Icons.favorite_border,
                      [const Color(0xFFFF007F), AppColors.neonViolet],
                      value: _health,
                      label: 'HP',
                    ),
                    const SizedBox(height: 12),
                    _buildStatBar(
                      Icons.sentiment_satisfied,
                      [AppColors.neonViolet, AppColors.neonCyan],
                      value: _mood,
                      label: 'Mood',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Animated pet display ───────────────────────────────────────
            GestureDetector(
              onTap: _triggerAction,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Aura glow dome
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

                  // Glass energy cylinder
                  Container(
                    width: 240,
                    height: 280,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(120),
                        bottom: Radius.circular(30),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.05),
                          Colors.transparent,
                          _currentAuraColor.withValues(alpha: 0.1),
                        ],
                      ),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                  ),

                  // Pedestal
                  Positioned(
                    bottom: 10,
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

                  // Pet (parallax + breathing + floating + jumping)
                  Positioned(
                    bottom: 25,
                    child: AnimatedBuilder(
                      animation: Listenable.merge([
                        _breatheController,
                        _floatController,
                        _feedController,
                      ]),
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            _parallaxX,
                            _parallaxY + _floatAnimation.value + _feedAnimation.value,
                          ),
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
                        );
                      },
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

  /// Stat bar that shows actual fill based on [value] (0.0–1.0).
  Widget _buildStatBar(
    IconData icon,
    List<Color> colors, {
    required double value,
    required String label,
  }) {
    const double barWidth = 130;
    const double barHeight = 10;

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
                color: AppColors.subtleText.withValues(alpha: 0.7),
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
                    color: Colors.white.withValues(alpha: 0.12),
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
            color: AppColors.subtleText,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
