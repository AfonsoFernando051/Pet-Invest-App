import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/di/dependency_injection.dart';

class PetShowcase extends StatefulWidget {
  const PetShowcase({super.key});

  @override
  State<PetShowcase> createState() => _PetShowcaseState();
}

class _PetShowcaseState extends State<PetShowcase> with SingleTickerProviderStateMixin {
  String _petAsset = 'assets/images/generated_dog.png';
  bool _isLoadingPet = true;

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

    _fetchMyPet();
  }

  @override
  void dispose() {
    _animationController.dispose();
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
      } else {
        if (mounted) setState(() => _isLoadingPet = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingPet = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      isAnimated: true,
      backgroundColor: AppColors.spaceDark.withValues(alpha: 0.4),
      borderColor: AppColors.neonCyan.withValues(alpha: 0.3),
      borderWidth: 1,
      borderRadius: 24,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16),
        child: Column(
          children: [
            // Status Bars
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
            // The pet image in a "dome" effect
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glowing background
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neonCyan.withValues(alpha: 0.15 + (_animationController.value * 0.15)), 
                            blurRadius: 40 + (_animationController.value * 20), 
                            spreadRadius: 10 + (_animationController.value * 10)
                          )
                        ],
                      ),
                    ),
                    // "Dome" gradient
                    Container(
                      width: 240,
                      height: 280,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(120), bottom: Radius.circular(30)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.1),
                            Colors.transparent,
                            AppColors.neonCyan.withValues(alpha: 0.05 + (_animationController.value * 0.05)),
                          ],
                        ),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1 + (_animationController.value * 0.1))),
                      ),
                    ),
                    // Pet Image
                    Positioned(
                      bottom: 20 + _floatAnimation.value,
                      child: Transform.scale(
                        scale: _breatheAnimation.value,
                        child: _isLoadingPet 
                        ? const CircularProgressIndicator(color: AppColors.neonCyan)
                        : Image.asset(
                          _petAsset, 
                          height: 220, 
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.pets, size: 100, color: Colors.white70),
                        ),
                      ),
                    ),
                    // Dome Base
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: 260,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppColors.spaceDark,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.neonCyan.withValues(alpha: 0.3 + (_animationController.value * 0.3)), 
                              blurRadius: 10 + (_animationController.value * 5), 
                              spreadRadius: 1
                            )
                          ]
                        ),
                      ),
                    )
                  ],
                );
              }
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
              BoxShadow(color: colors.first.withValues(alpha: 0.5), blurRadius: 6, spreadRadius: 1),
            ],
            border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.5), width: 1),
          ),
        ),
      ],
    );
  }
}
