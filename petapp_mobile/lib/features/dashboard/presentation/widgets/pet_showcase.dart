import 'dart:async';
import 'package:flutter/material.dart';
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
  // --- Data State ---
  double _currentPerformance = 10.0; // Mock performance value (-100 to 100)
  bool _isLoadingPet = true;
  String _petAsset = 'assets/images/generated_dog.png';

  // --- Animation Controllers ---
  late AnimationController _breatheController;
  late AnimationController _floatController;
  late AnimationController _glowController;
  late AnimationController _feedController;

  // --- Tweens ---
  late Animation<double> _breatheAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _feedAnimation;

  // --- Hardware Sensors ---
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
    // 1. Breathing (Subtle squish & stretch)
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
    
    _breatheAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOutSine),
    );

    // 2. Floating (Anti-gravity hover over pedestal)
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -6.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // 3. Glow Pulsing (Background aura intensity)
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.1, end: 0.5).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // 4. Feeding/Interacting (Quick jump)
    _feedController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Jump up, then bounce back down
    _feedAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: -30).chain(CurveTween(curve: Curves.easeOutCubic)), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: -30, end: 0).chain(CurveTween(curve: Curves.bounceOut)), weight: 50),
    ]).animate(_feedController);
  }

  void _initAccelerometer() {
    try {
      _accelerometerSubscription = accelerometerEventStream().listen((AccelerometerEvent event) {
        if (mounted) {
          setState(() {
            // Smoothly move the image opposite to device tilt.
            // Accelerometer X is side-to-side, Y is forward/backward
            _parallaxX = (event.x * -3.0).clamp(-20.0, 20.0);
            _parallaxY = (event.y * 3.0).clamp(-20.0, 20.0);
          });
        }
      });
    } catch (e) {
      debugPrint("Accelerometer not available: $e");
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
        
        setState(() {
          _petAsset = 'assets/images/generated_$specie.png';
          _isLoadingPet = false;
        });

        // Trigger feed/hello jump once loaded
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
      _feedController.forward(from: 0.0);
    }
  }

  Color get _currentAuraColor {
    // Dynamic color based on mock portfolio logic
    if (_currentPerformance < -10) {
      return Colors.redAccent;
    } else if (_currentPerformance < 0) {
      return AppColors.neonPurple;
    } else {
      return AppColors.neonCyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      isAnimated: true,
      backgroundColor: AppColors.spaceDark.withValues(alpha: 0.4),
      borderColor: _currentAuraColor.withValues(alpha: 0.3),
      borderWidth: 1,
      borderRadius: 24,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16),
        child: Column(
          children: [
            // Status Bars (Health/Mood)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatBar(Icons.favorite_border, [const Color(0xFFFF007F), const Color(0xFF8A2BE2)]),
                    const SizedBox(height: 12),
                    _buildStatBar(Icons.sentiment_satisfied, [const Color(0xFF8A2BE2), AppColors.neonCyan]),
                  ],
                )
              ],
            ),
            const SizedBox(height: 24),
            
            // Advanced Animated Pet Display
            Stack(
              alignment: Alignment.center,
              children: [
                // 1. Aura / Glow Dome
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
                          )
                        ],
                      ),
                    );
                  }
                ),
                
                // 2. The Glass/Energy Cylinder holding the pet
                Container(
                  width: 240,
                  height: 280,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(120), bottom: Radius.circular(30)),
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
                
                // 3. The Pedestal
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
                        )
                      ],
                      border: Border.all(color: _currentAuraColor.withValues(alpha: 0.5)),
                    ),
                  ),
                ),
                
                // 4. The Pet (with Parallax, Breathing, Floating, and Jumping)
                Positioned(
                  bottom: 25,
                  child: GestureDetector(
                    onTap: _triggerAction,
                    child: AnimatedBuilder(
                      animation: Listenable.merge([
                        _breatheController,
                        _floatController,
                        _feedController,
                      ]),
                      builder: (context, child) {
                        return Transform.translate(
                          // Parallax (Hardware) + Floating (Time) + Jumping (Event)
                          offset: Offset(
                            _parallaxX, 
                            _parallaxY + _floatAnimation.value + _feedAnimation.value
                          ),
                          child: Transform.scale(
                            scaleY: _breatheAnimation.value,
                            scaleX: 1.0 + (1.0 - _breatheAnimation.value), // Stretch opposite to breathing
                            child: _isLoadingPet 
                              ? const SizedBox(
                                  height: 220, 
                                  child: Center(child: CircularProgressIndicator())
                                )
                              : Image.asset(
                                  _petAsset,
                                  height: 220,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.pets, 
                                    size: 100, 
                                    color: Colors.white70
                                  ),
                                ),
                          ),
                        );
                      }
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBar(IconData icon, List<Color> colors) {
    return Row(
      children: [
        Icon(icon, color: colors.first, size: 24),
        const SizedBox(width: 12),
        Container(
          width: 140,
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            gradient: LinearGradient(colors: colors),
            boxShadow: [
              BoxShadow(
                color: colors.first.withValues(alpha: 0.5), 
                blurRadius: 6, 
                spreadRadius: 1
              ),
            ],
            border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.5), width: 1),
          ),
        ),
      ],
    );
  }
}
