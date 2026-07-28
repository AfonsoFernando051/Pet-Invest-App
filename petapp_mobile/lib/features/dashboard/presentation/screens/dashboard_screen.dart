import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../investment/presentation/screens/investment_configuration_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../widgets/pet_showcase.dart';
import '../widgets/rpg_attributes.dart';
import '../widgets/account_overview.dart';
import '../widgets/action_buttons.dart';
import '../widgets/recent_transactions.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // Shared background for all tabs
  Widget _buildBackground({required Widget child}) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Nebula image, darkened so content pops
        Image.asset(
          'assets/images/bg_nebula.png',
          fit: BoxFit.cover,
          color: Colors.black.withValues(alpha: 0.48),
          colorBlendMode: BlendMode.darken,
        ),
        child,
      ],
    );
  }

  // ── Page route helper ─────────────────────────────────────────────────────
  Route _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        ),
      ),
      transitionDuration: const Duration(milliseconds: 350),
    );
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.spaceBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Sair do Invest Game?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Tem certeza que deseja encerrar sua sessão?',
          style: TextStyle(color: AppColors.subtleText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.neonCyan)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair', style: TextStyle(color: AppColors.negativeRed)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      HapticFeedback.mediumImpact();
      await DI.authRepository.logout();
      if (mounted) {
        Navigator.of(context).pushReplacement(_fadeRoute(const LoginScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: _buildAppBarTitle(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white70),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white70),
            tooltip: 'Configurações',
            onPressed: () {
              Navigator.of(context).push(_fadeRoute(const SettingsScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.neonPurple),
            tooltip: 'Sair',
            onPressed: _confirmLogout,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBackground(
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

  // ── AppBar title — compact player HUD ────────────────────────────────────
  Widget _buildAppBarTitle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.7), width: 1.5),
            color: AppColors.spaceDark.withValues(alpha: 0.6),
          ),
          child: const Icon(Icons.person_outline, size: 18, color: AppColors.neonCyan),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Invest Game',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              'Nível 7 · Explorador',
              style: TextStyle(color: AppColors.neonCyan.withValues(alpha: 0.9), fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }

  // ── Home ──────────────────────────────────────────────────────────────────
  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PetShowcase(),
          const SizedBox(height: 8),

          _buildSectionLabel('STATUS DO EXPLORADOR'),
          const SizedBox(height: 8),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(flex: 4, child: SizedBox(height: 270, child: RpgAttributes())),
              SizedBox(width: 12),
              Expanded(flex: 5, child: SizedBox(height: 270, child: AccountOverview())),
            ],
          ),
          const SizedBox(height: 16),

          _buildSectionLabel('AÇÕES RÁPIDAS'),
          const SizedBox(height: 8),

          const ActionButtons(),
          const SizedBox(height: 16),

          _buildSectionLabel('ÚLTIMAS MISSÕES'),
          const SizedBox(height: 8),

          const RecentTransactions(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        color: AppColors.neonCyan.withValues(alpha: 0.5),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.0,
      ),
    );
  }

  // ── Wallet ────────────────────────────────────────────────────────────────
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
              Image.asset(
                'assets/images/generated_fox.png',
                height: 100,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.diamond,
                  size: 64,
                  color: AppColors.neonCyan,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Nenhum Ativo Detectado,\nComandante.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Adicione ativos para construir\nseu portfólio intergaláctico.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.subtleText, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.rocket_launch, color: Colors.white),
                label: const Text(
                  'Iniciar Missão de Investimento',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonViolet,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 8,
                  shadowColor: AppColors.neonViolet.withValues(alpha: 0.5),
                ),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).push(_fadeRoute(const InvestmentConfigurationScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Analytics ─────────────────────────────────────────────────────────────
  Widget _buildAnalyticsContent() {
    return Center(
      child: GlassCard(
        backgroundColor: AppColors.spaceDark.withValues(alpha: 0.6),
        borderColor: AppColors.neonCyan.withValues(alpha: 0.3),
        borderRadius: 24,
        borderWidth: 1,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_graph, size: 64, color: AppColors.neonCyan.withValues(alpha: 0.6)),
              const SizedBox(height: 16),
              const Text(
                'Análise Estratégica',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Centro de análise de ativos\nem construção, Comandante.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.subtleText, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Profile ───────────────────────────────────────────────────────────────
  Widget _buildProfileContent() {
    return Center(
      child: GlassCard(
        backgroundColor: AppColors.spaceDark.withValues(alpha: 0.6),
        borderColor: AppColors.neonPink.withValues(alpha: 0.3),
        borderRadius: 24,
        borderWidth: 1,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.manage_accounts, size: 64, color: AppColors.neonPink.withValues(alpha: 0.7)),
              const SizedBox(height: 16),
              const Text(
                'Perfil do Comandante',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Conquistas em breve.\nGerencie idioma e conta nas configurações.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.subtleText, fontSize: 14),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                icon: const Icon(Icons.settings_outlined, color: AppColors.neonPink),
                label: const Text(
                  'Configurações',
                  style: TextStyle(color: AppColors.neonPink, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.neonPink),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  Navigator.of(context).push(_fadeRoute(const SettingsScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Bottom Nav ────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border(top: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.3), width: 1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonCyan.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.neonCyan,
        unselectedItemColor: Colors.white38,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        currentIndex: _selectedIndex,
        onTap: (i) {
          HapticFeedback.selectionClick();
          setState(() => _selectedIndex = i);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(Icons.rocket_launch_outlined),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(Icons.rocket_launch),
            ),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.diamond_outlined),
            activeIcon: Icon(Icons.diamond),
            label: 'Carteira',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_graph),
            label: 'Análise',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts_outlined),
            activeIcon: Icon(Icons.manage_accounts),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
