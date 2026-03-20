import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/translator.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../home/presentation/screens/home_screen.dart';
import 'custom_text_field.dart';
import 'forgot_password_button.dart';
import 'login_button.dart';
import 'signup_button.dart';

class LoginCard extends StatefulWidget {
  const LoginCard({super.key});

  @override
  State<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
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
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
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
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white10,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.white20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.explore, size: 64, color: AppColors.white),
                const SizedBox(height: 16),
                Text(
                  Translator.translate(AppStrings.welcomeBack),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  Translator.translate(AppStrings.loginToContinue),
                  style: const TextStyle(color: AppColors.white70),
                ),
                const SizedBox(height: 24),
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
                const SizedBox(height: 24),
                LoginButton(
                  onPressed: _handleLogin,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16),
                const ForgotPasswordButton(),
                const SizedBox(height: 8),
                const SignupButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
