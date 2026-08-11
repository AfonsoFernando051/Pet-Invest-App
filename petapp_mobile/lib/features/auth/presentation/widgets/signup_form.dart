import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_tokens.dart';
import '../../../../core/utils/translator.dart';
import '../../../../core/utils/game_snack.dart';
import '../../../../core/utils/friendly_error_message.dart';
import '../../../../core/utils/password_policy.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../main.dart';
import 'custom_text_field.dart';
import 'signup_action_button.dart';
import 'already_have_account_button.dart';

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

    if (password != confirmPassword) {
      GameSnack.show(context, 'As senhas não coincidem.', isError: true);
      return;
    }

    final passwordError = PasswordPolicy.validate(password);
    if (passwordError != null) {
      GameSnack.show(context, passwordError, isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await DI.authRepository.register(name, email, password);
      
      // Auto-login since register doesn't return an accessToken
      await DI.authRepository.login(email, password);

      // Rebuilds fresh from `MyApp._getStartRoute()` — the single source of
      // truth for where a user belongs (meet pet / goal / tutorial /
      // portfolio choice / home) — instead of a separate, narrower redirect.
      if (mounted) {
        await Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MyApp()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        GameSnack.show(
          context,
          'Cadastro falhou: ${friendlyErrorMessage(e)}',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.person_add, size: 64, color: tokens.textPrimary),
        const SizedBox(height: 16),
        Text(
          Translator.translate(AppStrings.createAccount),
          style: TextStyle(
            color: tokens.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          Translator.translate(AppStrings.fillDetails),
          style: TextStyle(color: tokens.textSecondary),
        ),
        const SizedBox(height: 24),
        CustomTextField(
          hint: Translator.translate(AppStrings.nameHint),
          icon: Icons.person,
          controller: _nameController,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          hint: Translator.translate(AppStrings.emailOrUserHint),
          icon: Icons.email,
          controller: _emailController,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          hint: Translator.translate(AppStrings.passwordHint),
          icon: Icons.lock,
          obscure: true,
          controller: _passwordController,
        ),
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
