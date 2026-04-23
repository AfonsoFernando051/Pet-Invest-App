import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../investment/presentation/screens/investment_configuration_screen.dart';
import '../widgets/pet_showcase.dart';
import '../widgets/rpg_attributes.dart';
import '../widgets/account_overview.dart';
import '../widgets/action_buttons.dart';
import '../widgets/recent_transactions.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../investment/presentation/screens/investment_configuration_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0; // Início is selected

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: _buildTopTabBar(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.white70), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.neonPurple), 
            onPressed: () async {
              await DI.authRepository.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
              }
            }
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg_nebula.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: IndexedStack(
            index: _selectedIndex,
            children: [
              _buildHomeContent(),
              _buildWalletContent(),
              _buildAnalyticsContent(),
              _buildProfileContent(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // --- Screens ---
  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          const PetShowcase(),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(flex: 5, child: SizedBox(height: 250, child: RpgAttributes())),
              SizedBox(width: 16),
              Expanded(flex: 6, child: SizedBox(height: 250, child: AccountOverview())),
            ],
          ),
          const SizedBox(height: 16),
          const ActionButtons(),
          const SizedBox(height: 16),
          const RecentTransactions(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildWalletContent() {
    return Center(
      child: GlassCard(
        backgroundColor: AppColors.spaceDark.withValues(alpha: 0.6),
        borderColor: AppColors.neonCyan.withValues(alpha: 0.3),
        borderRadius: 24,
        borderWidth: 1,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_balance_wallet, size: 64, color: AppColors.neonCyan),
              const SizedBox(height: 16),
              const Text('Minha Carteira', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Seus ativos ficarão aqui.', style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Adicionar Novo Ativo', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8A2BE2),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InvestmentConfigurationScreen()));
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsContent() {
    return const Center(child: Text('Ambiente de Análise de Ações - Em Breve!', style: TextStyle(color: AppColors.neonCyan, fontSize: 16)));
  }

  Widget _buildProfileContent() {
    return const Center(child: Text('Perfil do Investidor e Opções - Em Breve!', style: TextStyle(color: Color(0xFFFF007F), fontSize: 16)));
  }

  // --- Top Tab Bar ---
  Widget _buildTopTabBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTopTab('Início', true),
          _buildTopTab('Meu Pet', false),
          _buildTopTab('Conquistas', false),
          _buildTopTab('Análises', false),
        ],
      ),
    );
  }

  Widget _buildTopTab(String text, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: isSelected
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.neonCyan, width: 2),
              color: AppColors.neonCyan.withValues(alpha: 0.2),
              boxShadow: [
                BoxShadow(color: AppColors.neonCyan.withValues(alpha: 0.4), blurRadius: 8, spreadRadius: 1)
              ]
            )
          : null,
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
    );
  }

  // --- Bottom Nav ---
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border(top: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.3), width: 1)),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.neonCyan,
        unselectedItemColor: Colors.white54,
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(Icons.home),
            ), 
            label: 'Início'
          ),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Carteira'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Análise'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
