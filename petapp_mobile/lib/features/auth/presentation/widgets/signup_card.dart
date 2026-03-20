import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/translator.dart';
import 'custom_text_field.dart';
import 'signup_action_button.dart';
import 'already_have_account_button.dart';

class SignupCard extends StatelessWidget {
  const SignupCard({super.key});

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
                    ),
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 16),
                    CustomTextField(
                      hint: Translator.translate(AppStrings.confirmPasswordHint),
                      icon: Icons.lock_outline,
                      obscure: true,
                    ),
                    const SizedBox(height: 24),
                    const SignupActionButton(),
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
