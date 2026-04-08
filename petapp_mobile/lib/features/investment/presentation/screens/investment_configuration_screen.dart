import 'package:flutter/material.dart';
import 'package:petapp_mobile/core/constants/app_colors.dart';
import 'package:petapp_mobile/core/di/dependency_injection.dart';
import 'package:petapp_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:petapp_mobile/features/investment/data/models/investment_type_enum.dart';
import 'package:petapp_mobile/features/investment/data/models/asset_registration_model.dart';
import 'package:petapp_mobile/core/widgets/glass_card.dart';

class InvestmentConfigurationScreen extends StatefulWidget {
  const InvestmentConfigurationScreen({super.key});

  @override
  State<InvestmentConfigurationScreen> createState() => _InvestmentConfigurationScreenState();
}

class _InvestmentConfigurationScreenState extends State<InvestmentConfigurationScreen> {
  final List<AssetRegistrationModel> _assets = [];
  bool _isLoading = false;
  bool _isFetchingQuote = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  
  InvestmentTypeEnum? _selectedType;
  DateTime? _selectedDate;

  final Map<InvestmentTypeEnum, String> _investmentLabels = {
    InvestmentTypeEnum.STOCKS: 'Ações',
    InvestmentTypeEnum.FIXED_INCOME: 'Renda Fixa',
    InvestmentTypeEnum.REAL_ESTATE: 'Fundos Imobiliários',
    InvestmentTypeEnum.CRYPTO: 'Criptomoedas',
    InvestmentTypeEnum.FUNDS: 'Fundos de Investimento',
    InvestmentTypeEnum.OTHERS: 'Outros',
  };

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  void _addAsset() {
    if (_formKey.currentState!.validate() && _selectedType != null && _selectedDate != null) {
      final asset = AssetRegistrationModel(
        name: _nameController.text,
        quantity: double.tryParse(_quantityController.text) ?? 0.0,
        purchasePrice: double.tryParse(_priceController.text) ?? 0.0,
        purchaseDate: _formatDate(_selectedDate!),
        type: _selectedType!,
      );

      setState(() {
        _assets.add(asset);
        _nameController.clear();
        _quantityController.clear();
        _priceController.clear();
        _selectedType = null;
        _selectedDate = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preencha todos os campos e selecione uma data/tipo.')));
    }
  }

  Future<void> _handleConfirm() async {
    if (_assets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Adicione pelo menos um ativo para continuar.')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await DI.investmentRepository.configureInvestments(_assets);
      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const DashboardScreen()));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Falha ao salvar investimentos: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.neonCyan,
              onPrimary: Colors.black,
              surface: AppColors.spaceDark,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildAutocompleteField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Autocomplete<Map<String, dynamic>>(
        optionsBuilder: (TextEditingValue textEditingValue) async {
          if (textEditingValue.text.length < 2) {
            return const Iterable<Map<String, dynamic>>.empty();
          }
          final results = await DI.investmentRepository.searchQuotes(textEditingValue.text);
          return results;
        },
        displayStringForOption: (Map<String, dynamic> option) {
          return option['symbol']?.toString() ?? option['stock']?.toString() ?? '';
        },
        onSelected: (Map<String, dynamic> selection) {
          setState(() {
            _nameController.text = selection['symbol']?.toString() ?? selection['stock']?.toString() ?? '';
            _priceController.text = selection['regularMarketPrice']?.toString() ?? selection['close']?.toString() ?? '';
          });
        },
        fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
          controller.addListener(() {
            _nameController.text = controller.text;
          });

          return TextFormField(
            controller: controller,
            focusNode: focusNode,
            onEditingComplete: onEditingComplete,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Nome/Ticker (ex: PETR4)',
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: AppColors.spaceDark.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.goldenBorder.withValues(alpha: 0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.goldenBorder.withValues(alpha: 0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.neonCyan),
              ),
            ),
            validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
          );
        },
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              color: Colors.transparent,
              elevation: 4.0,
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                constraints: const BoxConstraints(maxHeight: 250, maxWidth: 300),
                decoration: BoxDecoration(
                  color: AppColors.spaceDark.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.5)),
                ),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (BuildContext context, int index) {
                    final option = options.elementAt(index);
                    final symbol = option['symbol'] ?? option['stock'] ?? '';
                    final name = option['shortName'] ?? option['name'] ?? '';
                    return ListTile(
                      title: Text(
                        "$symbol - $name",
                        style: const TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        onSelected(option);
                      },
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, TextInputType type, {Widget? suffixIcon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: AppColors.spaceDark.withValues(alpha: 0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.goldenBorder.withValues(alpha: 0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.goldenBorder.withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.neonCyan),
          ),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<InvestmentTypeEnum>(
        value: _selectedType,
        isExpanded: true,
        dropdownColor: AppColors.spaceDark,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: 'Tipo de Investimento',
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: AppColors.spaceDark.withValues(alpha: 0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.goldenBorder.withValues(alpha: 0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.goldenBorder.withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.neonCyan),
          ),
        ),
        items: InvestmentTypeEnum.values.map((type) {
          return DropdownMenuItem(
            value: type,
            child: Text(
              _investmentLabels[type]!,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (val) => setState(() => _selectedType = val),
      ),
    );
  }

  Widget _buildDatePickerField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        onTap: _selectDate,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.spaceDark.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.goldenBorder.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _selectedDate == null ? 'Data de Compra' : "${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}",
                  style: TextStyle(color: _selectedDate == null ? Colors.white70 : Colors.white, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.calendar_today, color: AppColors.neonCyan),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Configuração de Ativos', style: TextStyle(color: Colors.white)),
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: isWide
                    ? Row(
                        children: [
                          Expanded(flex: 4, child: _buildLeftPanel()),
                          const SizedBox(width: 32),
                          Expanded(flex: 6, child: _buildRightPanel()),
                        ],
                      )
                    : _buildRightPanel(),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLeftPanel() {
    return GlassCard(
      isAnimated: true,
      backgroundColor: AppColors.spaceDark.withValues(alpha: 0.4),
      borderRadius: 24,
      borderColor: AppColors.neonCyan.withValues(alpha: 0.5),
      borderWidth: 2,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/fox_compass.png', height: 250),
            const SizedBox(height: 32),
            const Text(
              'Monte seu Portfólio',
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Registre seus ativos para que possamos monitorá-los e guiar a sua jornada financeira.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightPanel() {
    return GlassCard(
      backgroundColor: AppColors.spaceDark.withValues(alpha: 0.6),
      borderRadius: 24,
      borderColor: AppColors.goldenBorder.withValues(alpha: 0.2),
      borderWidth: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Adicionar Ativo',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildDropdown(),
                      _buildAutocompleteField(),
                      Row(
                        children: [
                          Expanded(child: _buildTextField(_quantityController, 'Qtd.', const TextInputType.numberWithOptions(decimal: true))),
                          const SizedBox(width: 8),
                          Expanded(child: _buildTextField(_priceController, 'Preço (R\$)', const TextInputType.numberWithOptions(decimal: true))),
                        ],
                      ),
                      _buildDatePickerField(),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.add, color: AppColors.neonCyan),
                        label: const Text('Adicionar', style: TextStyle(color: AppColors.neonCyan)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.neonCyan),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _addAsset,
                      ),
                      const SizedBox(height: 16),
                      if (_assets.isNotEmpty) ...[
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Registrados:', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _assets.length,
                          itemBuilder: (context, index) {
                            final a = _assets[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.all(0),
                              leading: const Icon(Icons.check_circle, color: AppColors.neonCyan),
                              title: Text(
                                a.name, 
                                style: const TextStyle(color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '${a.quantity} cotas a R\$ ${a.purchasePrice}', 
                                style: const TextStyle(color: Colors.white70),
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () {
                                  setState(() {
                                    _assets.removeAt(index);
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.neonPurple, AppColors.neonCyan],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(25),
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
          borderRadius: BorderRadius.circular(25),
          onTap: _isLoading ? null : _handleConfirm,
          child: Center(
            child: _isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text(
                    'Confirmar e Continuar',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }
}
