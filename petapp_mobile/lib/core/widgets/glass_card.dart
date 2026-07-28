import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:petapp_mobile/core/constants/app_colors.dart';

/// A real glassmorphism card with BackdropFilter blur.
/// All content placed on top of the nebula background will now correctly
/// show frosted-glass depth instead of a plain translucent rectangle.
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
    final effectiveBg = backgroundColor ?? AppColors.spaceDark.withValues(alpha: 0.55);
    final effectiveBorder = borderColor ?? AppColors.goldenBorder.withValues(alpha: 0.5);
    final radius = BorderRadius.circular(borderRadius);

    final inner = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: effectiveBg,
            borderRadius: radius,
            border: Border.all(color: effectiveBorder, width: borderWidth),
            boxShadow: boxShadow,
          ),
          child: child,
        ),
      ),
    );

    if (margin != null) {
      return Container(margin: margin, child: inner);
    }
    return inner;
  }
}
