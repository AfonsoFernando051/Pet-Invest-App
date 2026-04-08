import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/di/dependency_injection.dart';
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
          _buildPetShowcase(),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: SizedBox(height: 250, child: _buildRpgAttributes())),
              const SizedBox(width: 16),
              Expanded(flex: 6, child: SizedBox(height: 250, child: _buildAccountOverview())),
            ],
          ),
          const SizedBox(height: 16),
          _buildActionButtons(),
          const SizedBox(height: 16),
          _buildRecentTransactions(),
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

  // --- Center Pet Showcase ---
  Widget _buildPetShowcase() {
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
            Stack(
              alignment: Alignment.center,
              children: [
                // Glowing background
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppColors.neonCyan.withValues(alpha: 0.2), blurRadius: 40, spreadRadius: 20)
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
                        AppColors.neonCyan.withValues(alpha: 0.05),
                      ],
                    ),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                ),
                // Pet Image
                Positioned(
                  bottom: 20,
                  child: Image.asset(
                    'assets/images/generated_dog.png', 
                    height: 220, 
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.pets, size: 100, color: Colors.white70),
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
                      boxShadow: [BoxShadow(color: AppColors.neonCyan.withValues(alpha: 0.5), blurRadius: 10, spreadRadius: 1)]
                    ),
                  ),
                )
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
              BoxShadow(color: colors.first.withValues(alpha: 0.5), blurRadius: 6, spreadRadius: 1),
            ],
            border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.5), width: 1),
          ),
        ),
      ],
    );
  }

  // --- RPG Attributes ---
  Widget _buildRpgAttributes() {
    return GlassCard(
      backgroundColor: AppColors.spaceDark.withValues(alpha: 0.6),
      borderColor: AppColors.neonCyan.withValues(alpha: 0.3),
      borderRadius: 16,
      borderWidth: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Text('Atributos RPG', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Expanded(
              child: RadarChart(
                RadarChartData(
                  tickCount: 3,
                  ticksTextStyle: const TextStyle(fontSize: 8, color: Colors.transparent),
                  titlePositionPercentageOffset: 0.15,
                  radarBorderData: const BorderSide(color: Colors.white24),
                  gridBorderData: const BorderSide(color: Colors.white24, width: 1),
                  radarShape: RadarShape.polygon,
                  titleTextStyle: const TextStyle(color: Colors.white, fontSize: 10),
                  getTitle: (index, angle) {
                    switch (index) {
                      case 0: return const RadarChartTitle(text: 'DY');
                      case 1: return const RadarChartTitle(text: 'ROE');
                      case 2: return const RadarChartTitle(text: 'P/VP');
                      case 3: return const RadarChartTitle(text: 'Stock');
                      case 4: return const RadarChartTitle(text: 'P/VP');
                      case 5: return const RadarChartTitle(text: 'ROE');
                      default: return const RadarChartTitle(text: '');
                    }
                  },
                  dataSets: [
                    RadarDataSet(
                      fillColor: const Color(0xFF8A2BE2).withValues(alpha: 0.3),
                      borderColor: const Color(0xFF8A2BE2),
                      entryRadius: 0,
                      dataEntries: const [
                         RadarEntry(value: 8), RadarEntry(value: 6), RadarEntry(value: 5),
                         RadarEntry(value: 3), RadarEntry(value: 7), RadarEntry(value: 6),
                      ],
                      borderWidth: 2,
                    ),
                    RadarDataSet(
                      fillColor: AppColors.neonCyan.withValues(alpha: 0.3),
                      borderColor: AppColors.neonCyan,
                      entryRadius: 0,
                      dataEntries: const [
                         RadarEntry(value: 5), RadarEntry(value: 7), RadarEntry(value: 8),
                         RadarEntry(value: 4), RadarEntry(value: 6), RadarEntry(value: 5),
                      ],
                      borderWidth: 2,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildStatRow(Icons.healing, 'Regeneração', '2.00'),
            _buildStatRow(Icons.psychology, 'Inteligência', '1.00'),
            _buildStatRow(Icons.flash_on, 'Custo de Evocação', '1.00'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.neonCyan),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Colors.white70, fontSize: 10)),
            ],
          ),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- Account Overview ---
  Widget _buildAccountOverview() {
    return GlassCard(
      backgroundColor: AppColors.spaceDark.withValues(alpha: 0.6),
      borderColor: AppColors.neonCyan.withValues(alpha: 0.3),
      borderRadius: 16,
      borderWidth: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: Text('Visão Geral da Conta', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
            const SizedBox(height: 12),
            const Text('Patrimônio Total: R\$ 15,200.00', style: TextStyle(color: Colors.white, fontSize: 12)),
            const Text('Lucro do Dia: +R\$ 180.00 (+1.2%)', style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  minX: 0, maxX: 6, minY: 0, maxY: 6,
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [FlSpot(0, 1), FlSpot(1, 3), FlSpot(2, 2.5), FlSpot(3, 4), FlSpot(4, 3.5), FlSpot(5, 5), FlSpot(6, 4.5)],
                      isCurved: false,
                      color: AppColors.neonCyan,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: const [FlSpot(0, 1.5), FlSpot(1, 2.5), FlSpot(2, 1.5), FlSpot(3, 3), FlSpot(4, 2), FlSpot(5, 3.5), FlSpot(6, 3.5)],
                      isCurved: false,
                      color: const Color(0xFFFF007F),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegend(AppColors.neonCyan, 'Portfolio'),
                const SizedBox(width: 16),
                _buildLegend(const Color(0xFFFF007F), 'IBOV'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(width: 16, height: 4, color: color),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }

  // --- Action Buttons ---
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: _buildGradientButton(
            'Alimentar', 
            'Investir', 
            Icons.pets, 
            [const Color(0xFF8A2BE2), const Color(0xFFFF007F)],
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const InvestmentConfigurationScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildGradientButton(
            'Treinar', 
            'Analisar', 
            Icons.menu_book, 
            [const Color(0xFF8A2BE2), const Color(0xFFFF007F)],
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Análise de Ativos em construção...')));
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildGradientButton(
            'Missões', 
            'Metas', 
            Icons.flag, 
            [const Color(0xFF8A2BE2), AppColors.neonCyan],
            onTap: () {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sistema de Missões em breve!')));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGradientButton(String title, String subtitle, IconData icon, List<Color> colors, {VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: colors.last.withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 1)
            ]
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- Recent Transactions ---
  Widget _buildRecentTransactions() {
    return GlassCard(
       backgroundColor: AppColors.spaceDark.withValues(alpha: 0.6),
       borderColor: AppColors.neonCyan.withValues(alpha: 0.2),
       borderRadius: 16,
       borderWidth: 1,
       child: Padding(
         padding: const EdgeInsets.all(16),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.stretch,
           children: [
             const Text('Transações Recentes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
             const SizedBox(height: 16),
             _buildTransactionRow('PETR4', 'Flrx - 1,028%', 'R\$ 250.00', '22/03/2022', false),
             const Divider(color: Colors.white24, height: 24),
             _buildTransactionRow('WEGE3', 'Prx - 1,875%', '+R\$ 180.00', '22/04/2022', true),
           ],
         ),
       )
    );
  }

  Widget _buildTransactionRow(String ticker, String desc, String value, String date, bool isPositive) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ticker, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(value, style: TextStyle(color: isPositive ? Colors.greenAccent : Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            Text(date, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      ],
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
