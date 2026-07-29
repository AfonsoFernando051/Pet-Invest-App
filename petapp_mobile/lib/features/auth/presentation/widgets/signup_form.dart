import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/app_exceptions.dart';
import '../../../../core/utils/translator.dart';
import '../../../../core/utils/game_snack.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/di/dependency_injection.dart';
import 'custom_text_field.dart';
import 'password_requirements_checklist.dart';
import 'signup_action_button.dart';
import 'already_have_account_button.dart';
import '../../../../core/utils/auth_navigation_utils.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _showPasswordRequirements = false;
  String _password = '';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      GameSnack.show(context, 'Preencha todos os campos obrigatórios.', isError: true);
      return;
    }

    if (!Validators.isValidEmail(email)) {
      GameSnack.show(context, 'Digite um e-mail válido.', isError: true);
      return;
    }

    if (!isPasswordValid(password)) {
      setState(() => _showPasswordRequirements = true);
      GameSnack.show(context, 'A senha não atende aos requisitos mínimos.', isError: true);
      return;
    }

    if (password != confirmPassword) {
      GameSnack.show(context, 'As senhas não coincidem.', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await DI.authRepository.register(name, email, password);

      // Auto-login since register doesn't return an accessToken
      await DI.authRepository.login(email, password);

      if (!mounted) return;
      await AuthNavigationUtils.handlePostAuthRedirect(context);
    } catch (e) {
      if (mounted) {
        GameSnack.show(context, friendlyErrorMessage(e), isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.person_add, size: 64, color: AppColors.white),
        const SizedBox(height: 16),
        Text(
          Translator.translate(AppStrings.createAccount),
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          Translator.translate(AppStrings.fillDetails),
          style: const TextStyle(color: AppColors.white70),
        ),
        const SizedBox(height: 24),
        CustomTextField(
          hint: Translator.translate(AppStrings.nameHint),
          icon: Icons.person,
          controller: _nameController,
          maxLength: Validators.nameMaxLength,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          hint: Translator.translate(AppStrings.emailOrUserHint),
          icon: Icons.email,
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          hint: Translator.translate(AppStrings.passwordHint),
          icon: Icons.lock,
          obscure: true,
          controller: _passwordController,
          onChanged: (value) => setState(() {
            _password = value;
            if (value.isNotEmpty) _showPasswordRequirements = true;
          }),
        ),
        if (_showPasswordRequirements) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: PasswordRequirementsChecklist(password: _password),
          ),
        ],
        const SizedBox(height: 16),
        CustomTextField(
          hint: Translator.translate(AppStrings.confirmPasswordHint),
          icon: Icons.lock_outline,
          obscure: true,
          controller: _confirmPasswordController,
        ),
        const SizedBox(height: 24),
        SignupActionButton(
          onPressed: _handleRegister,
          isLoading: _isLoading,
        ),
        const SizedBox(height: 16),
        const AlreadyHaveAccountButton(),
      ],
    );
  }
}
