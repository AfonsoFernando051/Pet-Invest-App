import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
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
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.explore, size: 64, color: AppColors.white),
                SizedBox(height: 16),
                Text(
                  AppStrings.welcomeBack,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  AppStrings.loginToContinue,
                  style: TextStyle(color: AppColors.white70),
                ),
                SizedBox(height: 24),
                CustomTextField(
                  hint: AppStrings.emailOrUserHint,
                  icon: Icons.email,
                ),
                SizedBox(height: 16),
                CustomTextField(
                  hint: AppStrings.passwordHint,
                  icon: Icons.lock,
                  obscure: true,
                ),
                SizedBox(height: 24),
                LoginButton(),
                SizedBox(height: 16),
                Text(
                  AppStrings.forgotPassword,
                  style: TextStyle(color: AppColors.white70),
                ),
                SizedBox(height: 8),
                Text(
                  AppStrings.noAccountSignUp,
                  style: TextStyle(color: AppColors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
