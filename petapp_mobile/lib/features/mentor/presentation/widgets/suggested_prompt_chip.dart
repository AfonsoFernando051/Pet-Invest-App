import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petapp_mobile/core/constants/app_colors.dart';

/// A tappable suggested-question chip shown when the conversation is empty,
/// so a new user isn't staring at a blank input field.
class SuggestedPromptChip extends StatelessWidget {
  const SuggestedPromptChip({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.spaceDark.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.35)),
          ),
          child: Text(
            label,
            style: const TextStyle(color: AppColors.subtleText, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
