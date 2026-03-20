import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/translator.dart';
import 'custom_text_field.dart';
import 'login_button.dart';

class LoginCard extends StatelessWidget {
  const LoginCard({super.key});

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
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  hint: Translator.translate(AppStrings.passwordHint),
                  icon: Icons.lock,
                  obscure: true,
                ),
                const SizedBox(height: 24),
                const LoginButton(),
                const SizedBox(height: 16),
                Text(
                  Translator.translate(AppStrings.forgotPassword),
                  style: const TextStyle(color: AppColors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  Translator.translate(AppStrings.noAccountSignUp),
                  style: const TextStyle(color: AppColors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
