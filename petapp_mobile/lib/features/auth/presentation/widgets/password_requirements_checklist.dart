import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';

/// Real-time feedback for the signup password field: each rule lights up
/// green as soon as it's satisfied, so the user sees progress while typing
/// instead of hitting one opaque error after submitting.
class PasswordRequirementsChecklist extends StatelessWidget {
  const PasswordRequirementsChecklist({super.key, required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final rule in passwordRules) _RequirementRow(rule: rule, password: password),
      ],
    );
  }
}

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({required this.rule, required this.password});

  final PasswordRule rule;
  final String password;

  @override
  Widget build(BuildContext context) {
    final met = rule.isMet(password);
    final color = met ? AppColors.positiveGreen : AppColors.white54;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.circle_outlined,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            rule.label,
            style: TextStyle(color: color, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
