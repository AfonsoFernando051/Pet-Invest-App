import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/translator.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../onboarding/presentation/screens/onboarding_screen.dart';
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

      final status = await DI.onboardingRepository.getStatus();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => status.hasAnswered
                ? const HomeScreen()
                : const OnboardingScreen(),
          ),
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
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 32),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  width: 340,
                  padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                  decoration: BoxDecoration(
                    color: AppColors.white10.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.neonPurple.withValues(alpha: 0.3), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.spaceDark.withValues(alpha: 0.5),
                        blurRadius: 30,
                        spreadRadius: -5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        Translator.translate(AppStrings.welcomeBack),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        Translator.translate(AppStrings.loginToContinue),
                        style: const TextStyle(color: AppColors.white70),
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
                      const SizedBox(height: 32),
                      LoginButton(
                        onPressed: _handleLogin,
                        isLoading: _isLoading,
                      ),
                      const SizedBox(height: 16),
                      const ForgotPasswordButton(),
                      const SizedBox(height: 16),
                      const SignupButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: -70, // Shifted up to overlap the top border significantly
            child: Container(
              height: 140,
              width: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: AppColors.neonCyan.withValues(alpha: 0.5), blurRadius: 20, spreadRadius: 2),
                  BoxShadow(color: AppColors.neonPink.withValues(alpha: 0.4), blurRadius: 30, spreadRadius: -5),
                  BoxShadow(color: AppColors.neonPurple.withValues(alpha: 0.3), blurRadius: 40, spreadRadius: 10),
                ],
                border: Border.all(color: AppColors.white20, width: 2),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/magic_fox.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.spaceDark.withValues(alpha: 0.8),
                      ),
                      child: const Icon(Icons.person_outline, size: 40, color: AppColors.neonCyan),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
