import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:petapp_mobile/core/constants/app_colors.dart';
import 'package:petapp_mobile/core/di/dependency_injection.dart';
import 'package:petapp_mobile/features/home/presentation/screens/home_screen.dart';
import 'package:petapp_mobile/features/pet/data/models/pet_specie_enum.dart';

class PetConfigurationScreen extends StatefulWidget {
  const PetConfigurationScreen({super.key});

  @override
  State<PetConfigurationScreen> createState() => _PetConfigurationScreenState();
}

class _PetConfigurationScreenState extends State<PetConfigurationScreen> {
  PetSpecieEnum _selectedSpecie = PetSpecieEnum.DOG;
  bool _isLoading = false;

  final Map<PetSpecieEnum, IconData> _specieIcons = {
    PetSpecieEnum.DOG: Icons.pets,
    PetSpecieEnum.CAT: Icons.cruelty_free,
    PetSpecieEnum.WOLF: Icons.nightlight_round,
    PetSpecieEnum.FOX: Icons.local_fire_department,
    PetSpecieEnum.BEAR: Icons.catching_pokemon,
    PetSpecieEnum.LION: Icons.star,
  };

  Future<void> _handleSelectType() async {
    setState(() => _isLoading = true);
    try {
      await DI.petRepository.configurePet(_selectedSpecie);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save pet: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.spaceDark,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Select Your PET Companion',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Pet Laboratory',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            
            // Main visual capsule
            Expanded(
              flex: 2,
              child: Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.neonCyan.withValues(alpha: 0.2),
                        Colors.transparent
                      ],
                      radius: 0.8,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glass capsule base
                      Positioned(
                        bottom: 0,
                        child: Container(
                          width: 200,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.spaceBlue,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.neonCyan.withValues(alpha: 0.5),
                                blurRadius: 15,
                                spreadRadius: -5,
                              )
                            ],
                          ),
                        ),
                      ),
                      // Pet presentation
                      Icon(
                        _specieIcons[_selectedSpecie],
                        size: 150,
                        color: AppColors.white.withValues(alpha: 0.9),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Grid of options
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: PetSpecieEnum.values.length,
                  itemBuilder: (context, index) {
                    final specie = PetSpecieEnum.values[index];
                    final isSelected = _selectedSpecie == specie;
                    
                    return GestureDetector(
                      onTap: () => setState(() => _selectedSpecie = specie),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected 
                            ? AppColors.neonCyan.withValues(alpha: 0.1) 
                            : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.neonCyan : Colors.white10,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _specieIcons[specie],
                              color: isSelected ? AppColors.neonCyan : Colors.white54,
                              size: 40,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              specie.name,
                              style: TextStyle(
                                color: isSelected ? AppColors.neonCyan : Colors.white54,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Select button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSelectType,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Select type',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
