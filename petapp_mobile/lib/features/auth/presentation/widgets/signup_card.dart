import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/translator.dart';
import '../../../../core/di/dependency_injection.dart';
import 'custom_text_field.dart';
import 'signup_action_button.dart';
import 'already_have_account_button.dart';

class SignupCard extends StatefulWidget {
  const SignupCard({super.key});

  @override
  State<SignupCard> createState() => _SignupCardState();
}

class _SignupCardState extends State<SignupCard> {
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
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in required fields')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await DI.authRepository.register(email, password);
      
      // Auto-login since register doesn't return an accessToken
      await DI.authRepository.login(email, password);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration and Login successful!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${e.toString().replaceAll('Exception: ', '')}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        type: MaterialType.transparency,
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
              child: SingleChildScrollView(
                child: Column(
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
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
