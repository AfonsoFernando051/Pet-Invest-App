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
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: AppColors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.white70),
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.white54),
        filled: true,
        fillColor: AppColors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
