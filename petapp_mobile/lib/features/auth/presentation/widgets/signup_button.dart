import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/translator.dart';

class SignupButton extends StatelessWidget {
  const SignupButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Lógica para navegação para tela de cadastro
      },
      child: Text(
        Translator.translate(AppStrings.noAccountSignUp),
        style: const TextStyle(color: AppColors.white),
      ),
    );
  }
}
