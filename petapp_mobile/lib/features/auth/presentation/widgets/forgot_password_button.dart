import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/game_snack.dart';
import '../../../../core/utils/translator.dart';

class ForgotPasswordButton extends StatelessWidget {
  const ForgotPasswordButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        GameSnack.show(
          context,
          'Recuperação de senha ainda não está disponível. Entre em contato com o suporte.',
        );
      },
      child: Text(
        Translator.translate(AppStrings.forgotPassword),
        style: const TextStyle(
          color: AppColors.white70,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.white70,
        ),
      ),
    );
  }
}
