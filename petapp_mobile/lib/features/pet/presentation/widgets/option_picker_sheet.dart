import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';

/// A premium, space-themed modal bottom sheet for picking one value out of a
/// small enum-like list — used by the pet profile screen's "Meta Principal"
/// and "Horizonte de Tempo" selectors, which previously just displayed
/// static text with no way to actually change it.
Future<T?> showOptionPickerSheet<T>(
  BuildContext context, {
  required String title,
  required List<T> options,
  required T selected,
  required String Function(T) labelOf,
  required String Function(T) descriptionOf,
  required IconData Function(T) iconOf,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      final tokens = context.colors;
      return Container(
        decoration: BoxDecoration(
          color: tokens.surfaceElevated,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: tokens.divider, borderRadius: BorderRadius.circular(4)),
              ),
            ),
            Text(
              title,
              style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.bold, fontSize: 17),
            ),
            const SizedBox(height: 12),
            for (final option in options)
              _OptionTile<T>(
                option: option,
                isSelected: option == selected,
                label: labelOf(option),
                description: descriptionOf(option),
                icon: iconOf(option),
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.of(context).pop(option);
                },
              ),
          ],
        ),
      );
    },
  );
}

class _OptionTile<T> extends StatelessWidget {
  const _OptionTile({
    required this.option,
    required this.isSelected,
    required this.label,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  final T option;
  final bool isSelected;
  final String label;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.neonCyan.withValues(alpha: 0.12) : tokens.textPrimary.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.neonCyan.withValues(alpha: 0.6) : tokens.textPrimary.withValues(alpha: 0.1),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (isSelected ? AppColors.neonCyan : tokens.textPrimary).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: isSelected ? AppColors.neonCyan : tokens.textSecondary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: tokens.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(description, style: TextStyle(color: tokens.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              if (isSelected) const Icon(Icons.check_circle, color: AppColors.neonCyan, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
