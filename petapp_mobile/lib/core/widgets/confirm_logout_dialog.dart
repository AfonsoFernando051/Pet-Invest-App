import 'package:flutter/material.dart';
import 'package:petapp_mobile/core/constants/app_colors.dart';
import 'package:petapp_mobile/core/constants/app_strings.dart';
import 'package:petapp_mobile/core/utils/translator.dart';

/// The app's single logout-confirmation dialog, shown from both Dashboard
/// and Settings. Centralizing it means there's exactly one place that needs
/// to stay in sync with `Translator`/`AppStrings` — previously each screen
/// implemented its own copy, and only one of them was actually localized.
class ConfirmLogoutDialog {
  ConfirmLogoutDialog._();

  /// Shows the dialog and resolves to `true` if the user confirmed logout.
  static Future<bool> show(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.spaceBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          Translator.translate(AppStrings.logoutConfirmTitle),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          Translator.translate(AppStrings.logoutConfirmMessage),
          style: const TextStyle(color: AppColors.subtleText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(Translator.translate(AppStrings.cancelButton), style: const TextStyle(color: AppColors.neonCyan)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(Translator.translate(AppStrings.logoutButton), style: const TextStyle(color: AppColors.negativeRed)),
          ),
        ],
      ),
    );
    return confirmed == true;
  }
}
