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
      child: SingleChildScrollView(
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  width: 340,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.goldenBorder.withValues(alpha: 0.5), width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.spaceBlue.withValues(alpha: 0.2),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Large integrated Fox Image with ShaderMask fading out
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        child: ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.white, Colors.white, Colors.transparent],
                              stops: [0.0, 0.7, 1.0],
                            ).createShader(bounds);
                          },
                          blendMode: BlendMode.dstIn,
                          child: Image.asset(
                            'assets/images/magic_fox.jpg',
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                alignment: Alignment.center,
                                child: const Icon(Icons.broken_image, color: AppColors.white54, size: 50),
                              );
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                        child: Column(
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
                            const SizedBox(height: 24),
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
                            const SizedBox(height: 16),
                            const ForgotPasswordButton(),
                            const SizedBox(height: 16),
                            const SignupButton(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
           // Floating avatar top icon
          Positioned(
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white10.withValues(alpha: 0.2),
                border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.5), width: 1.5),
                boxShadow: [
                  BoxShadow(color: AppColors.neonCyan.withValues(alpha: 0.2), blurRadius: 10, spreadRadius: 1),
                ],
              ),
              child: const Icon(Icons.person_outline, size: 36, color: AppColors.white),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
