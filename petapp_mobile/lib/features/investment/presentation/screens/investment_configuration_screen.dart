import 'package:flutter/material.dart';
import 'package:petapp_mobile/core/constants/app_colors.dart';
import 'package:petapp_mobile/core/di/dependency_injection.dart';
import 'package:petapp_mobile/features/home/presentation/screens/home_screen.dart';
import 'package:petapp_mobile/features/investment/data/models/investment_type_enum.dart';
import 'package:petapp_mobile/core/widgets/glass_card.dart';

class InvestmentConfigurationScreen extends StatefulWidget {
  const InvestmentConfigurationScreen({super.key});

  @override
  State<InvestmentConfigurationScreen> createState() => _InvestmentConfigurationScreenState();
}

class _InvestmentConfigurationScreenState extends State<InvestmentConfigurationScreen> {
  final Set<InvestmentTypeEnum> _selectedInvestments = {};
  bool _isLoading = false;

  final Map<InvestmentTypeEnum, String> _investmentLabels = {
    InvestmentTypeEnum.STOCKS: 'Stocks & Equities',
    InvestmentTypeEnum.FIXED_INCOME: 'Fixed Income',
    InvestmentTypeEnum.REAL_ESTATE: 'Real Estate (REITs)',
    InvestmentTypeEnum.CRYPTO: 'Cryptocurrency',
    InvestmentTypeEnum.FUNDS: 'Mutual & ETFs',
    InvestmentTypeEnum.OTHERS: 'Other Assets',
  };

  final Map<InvestmentTypeEnum, IconData> _investmentIcons = {
    InvestmentTypeEnum.STOCKS: Icons.trending_up,
    InvestmentTypeEnum.FIXED_INCOME: Icons.account_balance,
    InvestmentTypeEnum.REAL_ESTATE: Icons.home_work,
    InvestmentTypeEnum.CRYPTO: Icons.currency_bitcoin,
    InvestmentTypeEnum.FUNDS: Icons.pie_chart,
    InvestmentTypeEnum.OTHERS: Icons.category,
  };

  Future<void> _handleConfirm() async {
    if (_selectedInvestments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one investment type.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await DI.investmentRepository.configureInvestments(_selectedInvestments.toList());
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save investments: \${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleInvestment(InvestmentTypeEnum type) {
    setState(() {
      if (_selectedInvestments.contains(type)) {
        _selectedInvestments.remove(type);
      } else {
        _selectedInvestments.add(type);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Investment Profile', style: TextStyle(color: Colors.white)),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Text(
                    'What kinds of investments do you hold?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: InvestmentTypeEnum.values.length,
                    itemBuilder: (context, index) {
                      final type = InvestmentTypeEnum.values[index];
                      final isSelected = _selectedInvestments.contains(type);
                      return GestureDetector(
                        onTap: () => _toggleInvestment(type),
                        child: GlassCard(
                          isAnimated: true,
                          backgroundColor: isSelected ? AppColors.neonCyan.withValues(alpha: 0.2) : AppColors.spaceDark.withValues(alpha: 0.6),
                          borderRadius: 20,
                          borderColor: isSelected ? AppColors.neonCyan : AppColors.goldenBorder.withValues(alpha: 0.3),
                          borderWidth: isSelected ? 2 : 1,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.neonCyan.withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  )
                                ]
                              : [],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _investmentIcons[type],
                                size: 40,
                                color: isSelected ? Colors.white : Colors.white70,
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  _investmentLabels[type]!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.white70,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildConfirmButton(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
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
        boxShadow: [
          BoxShadow(
            color: AppColors.neonPurple.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: _isLoading ? null : _handleConfirm,
          child: Center(
            child: _isLoading
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text(
                    'Confirm & Continue',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }
}
