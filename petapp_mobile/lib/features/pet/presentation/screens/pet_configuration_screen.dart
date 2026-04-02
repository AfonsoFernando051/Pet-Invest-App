import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:petapp_mobile/core/constants/app_colors.dart';
import 'package:petapp_mobile/core/di/dependency_injection.dart';
import 'package:petapp_mobile/features/home/presentation/screens/home_screen.dart';
import 'package:petapp_mobile/features/pet/data/models/pet_specie_enum.dart';
import 'package:fl_chart/fl_chart.dart';

class PetConfigurationScreen extends StatefulWidget {
  const PetConfigurationScreen({super.key});

  @override
  State<PetConfigurationScreen> createState() => _PetConfigurationScreenState();
}

class _PetConfigurationScreenState extends State<PetConfigurationScreen> with SingleTickerProviderStateMixin {
  PetSpecieEnum _selectedSpecie = PetSpecieEnum.DOG;
  bool _isLoading = false;
  String _selectedGoal = 'Growth';
  String _selectedHorizon = '1 years';

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
    super.dispose();
  }

  final Map<PetSpecieEnum, IconData> _specieIcons = {
    PetSpecieEnum.CAT: Icons.cruelty_free,
    PetSpecieEnum.DOG: Icons.pets,
    PetSpecieEnum.FOX: Icons.local_fire_department,
    PetSpecieEnum.WOLF: Icons.nightlight_round,
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('PET Profile', style: TextStyle(color: Colors.white)),
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.spaceDark.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.goldenBorder.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ]
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Seu PET Ativo',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _buildActivePetCapsule(),
          ),
          const SizedBox(height: 20),
          _buildPetSelector(),
          const SizedBox(height: 16),
          _buildDropdown('Main Goal: Reação to Drop', _selectedGoal, (v) => setState(() => _selectedGoal = v!)),
          const SizedBox(height: 12),
          _buildDropdown('Time Horizon, Market Action', _selectedHorizon, (v) => setState(() => _selectedHorizon = v!)),
          const SizedBox(height: 24),
          _buildConfirmButton(),
        ],
      ),
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
                borderRadius: BorderRadius.circular(32),
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
                image: DecorationImage(
                  image: AssetImage('assets/images/generated_${_selectedSpecie.name.toLowerCase()}.png'),
                  fit: BoxFit.cover,
                ),
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
          return GestureDetector(
            onTap: () => setState(() => _selectedSpecie = specie),
            child: Container(
              width: 70,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.neonCyan.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.neonCyan : Colors.white.withValues(alpha: 0.2),
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
                        image: AssetImage('assets/images/generated_${specie.name.toLowerCase()}.png'),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    specie.name[0].toUpperCase() + specie.name.substring(1).toLowerCase(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
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

  Widget _buildDropdown(String title, String value, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(title.contains('Goal') ? Icons.track_changes : Icons.access_time, color: Colors.white70, size: 20),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('Goal: $value', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ],
          ),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
        ],
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
                : const Text(
                    'Confirmar Seleção & Voltar',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildRightPanel() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.spaceDark.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonCyan.withValues(alpha: 0.1),
            blurRadius: 15,
            spreadRadius: 2,
          )
        ]
      ),
      child: Stack(
        children: [
          // Background decorative chart
          Positioned(
            top: 20,
            left: -50,
            child: Opacity(
              opacity: 0.5,
              child: SizedBox(
                width: 250,
                height: 250,
                child: _buildRadarChart(false),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: _buildRadarChart(true),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('PET-Invest Valor:', style: TextStyle(color: Colors.white70, fontSize: 14)),
                              Text('R\$ 8,250.00', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: const [
                              Text('Desempenho:', style: TextStyle(color: Colors.white70, fontSize: 14)),
                              Text('+15.2%', style: TextStyle(color: AppColors.neonCyan, fontSize: 20, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Divider(color: Colors.white24),
                      ),
                      _buildStatRow(Icons.healing, 'Regeneração', '2,00'),
                      const SizedBox(height: 12),
                      _buildStatRow(Icons.psychology, 'Inteligência', '1,0'),
                      const SizedBox(height: 12),
                      _buildStatRow(Icons.monetization_on, 'Custo de Evocação', '1,00'),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarChart(bool main) {
    return RadarChart(
      RadarChartData(
        dataSets: [
          RadarDataSet(
            fillColor: AppColors.neonCyan.withValues(alpha: 0.2),
            borderColor: AppColors.neonCyan,
            entryRadius: 0,
            dataEntries: [
              const RadarEntry(value: 8),
              const RadarEntry(value: 5),
              const RadarEntry(value: 7),
              const RadarEntry(value: 6),
            ],
            borderWidth: 2,
          ),
          RadarDataSet(
            fillColor: AppColors.goldenBorder.withValues(alpha: 0.2),
            borderColor: AppColors.goldenBorder,
            entryRadius: 0,
            dataEntries: [
              const RadarEntry(value: 6),
              const RadarEntry(value: 8),
              const RadarEntry(value: 4),
              const RadarEntry(value: 9),
            ],
            borderWidth: 2,
          ),
        ],
        radarBackgroundColor: Colors.transparent,
        borderData: FlBorderData(show: false),
        radarBorderData: const BorderSide(color: Colors.white24),
        titlePositionPercentageOffset: 0.2,
        titleTextStyle: TextStyle(color: Colors.white.withValues(alpha: main ? 0.8 : 0.4), fontSize: main ? 14 : 10),
        getTitle: (index, angle) {
          switch (index) {
            case 0: return const RadarChartTitle(text: 'DY');
            case 1: return const RadarChartTitle(text: 'ROE');
            case 2: return const RadarChartTitle(text: 'P/VP');
            case 3: return const RadarChartTitle(text: 'Stock');
            default: return const RadarChartTitle(text: '');
          }
        },
        tickCount: 3,
        ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 10),
        tickBorderData: const BorderSide(color: Colors.white12),
        gridBorderData: const BorderSide(color: Colors.white24, width: 2),
      ),
      swapAnimationDuration: const Duration(milliseconds: 150),
      swapAnimationCurve: Curves.linear,
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.neonCyan, size: 20),
        ),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
        const Spacer(),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
