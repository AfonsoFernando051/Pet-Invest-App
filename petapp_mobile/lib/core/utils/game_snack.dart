import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petapp_mobile/core/constants/app_colors.dart';

/// Utility for themed, branded snack bars.
/// Replaces all raw ScaffoldMessenger.showSnackBar calls.
class GameSnack {
  GameSnack._();

  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
    bool isSuccess = false,
  }) {
    final color = isError
        ? AppColors.negativeRed.withValues(alpha: 0.92)
        : isSuccess
            ? AppColors.positiveGreen.withValues(alpha: 0.92)
            : AppColors.spaceBlue.withValues(alpha: 0.95);

    final icon = isError
        ? Icons.error_outline
        : isSuccess
            ? Icons.check_circle_outline
            : Icons.info_outline;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isError
                ? AppColors.negativeRed
                : isSuccess
                    ? AppColors.positiveGreen
                    : AppColors.neonCyan.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Convenience: light haptic + show
  static void showWithHaptic(
    BuildContext context,
    String message, {
    bool isError = false,
    bool isSuccess = false,
  }) {
    HapticFeedback.lightImpact();
    show(context, message, isError: isError, isSuccess: isSuccess);
  }
}
