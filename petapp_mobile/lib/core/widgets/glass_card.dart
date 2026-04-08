import 'package:flutter/material.dart';
import 'package:petapp_mobile/core/constants/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? borderColor;
  final Color? backgroundColor;
  final double borderRadius;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;
  final bool isAnimated;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderColor,
    this.backgroundColor,
    this.borderRadius = 24.0,
    this.borderWidth = 1.5,
    this.boxShadow,
    this.isAnimated = false,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: backgroundColor ?? AppColors.spaceDark.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? AppColors.goldenBorder.withValues(alpha: 0.5),
        width: borderWidth,
      ),
      boxShadow: boxShadow,
    );

    if (isAnimated) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: padding,
        margin: margin,
        decoration: decoration,
        child: child,
      );
    }
    
    return Container(
      padding: padding,
      margin: margin,
      decoration: decoration,
      child: child,
    );
  }
}
