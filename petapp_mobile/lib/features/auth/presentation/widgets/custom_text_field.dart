import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white10,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.neonCyan, width: 1.5),
        boxShadow: [
          // Outer neon glow
          BoxShadow(
            color: AppColors.neonCyan.withValues(alpha: 0.5),
            blurRadius: 10,
            spreadRadius: 1,
          ),
          // Inner neon glow
          BoxShadow(
            color: AppColors.neonCyan.withValues(alpha: 0.2),
            blurRadius: 5,
            spreadRadius: -2,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: AppColors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.neonCyan),
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.white54),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
