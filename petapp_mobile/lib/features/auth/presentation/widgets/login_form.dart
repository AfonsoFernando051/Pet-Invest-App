import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/translator.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../onboarding/presentation/screens/onboarding_screen.dart';
import '../../../pet/presentation/screens/pet_configuration_screen.dart';
import 'custom_text_field.dart';
import 'forgot_password_button.dart';
import 'login_button.dart';
import 'signup_button.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await DI.authRepository.login(email, password);

      final status = await DI.onboardingRepository.getStatus();
      if (mounted) {
        if (!status.hasAnswered) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          );
          return;
        }

        final hasPet = await DI.petRepository.getPetStatus();
        if (mounted) {
          if (!hasPet) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const PetConfigurationScreen()),
            );
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.toString().replaceAll('Exception: ', '')}')),
        );
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
        Text(
          Translator.translate(AppStrings.welcomeBack),
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          Translator.translate(AppStrings.loginToContinue),
          style: const TextStyle(color: AppColors.white70, fontSize: 14),
        ),
        const SizedBox(height: 32),
        CustomTextField(
          hint: Translator.translate(AppStrings.emailOrUserHint),
          icon: Icons.email_outlined,
          controller: _emailController,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          hint: Translator.translate(AppStrings.passwordHint),
          icon: Icons.lock_outline,
          obscure: true,
          controller: _passwordController,
        ),
        const SizedBox(height: 24),
        LoginButton(
          onPressed: _handleLogin,
          isLoading: _isLoading,
        ),
        const SizedBox(height: 24),
        const ForgotPasswordButton(),
        const SizedBox(height: 16),
        const SignupButton(),
      ],
    );
  }
}
