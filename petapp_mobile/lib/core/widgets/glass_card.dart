import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:petapp_mobile/core/constants/app_colors.dart';
import 'package:petapp_mobile/core/theme/app_color_tokens.dart';

/// A real glassmorphism card with BackdropFilter blur.
/// All content placed on top of the nebula background will now correctly
/// show frosted-glass depth instead of a plain translucent rectangle.
///
/// Default background/border adapt to the active theme via `context.colors`
/// — pass explicit [backgroundColor]/[borderColor] only when a card needs a
/// specific per-feature accent (e.g. the pink companion card border), since
/// those accent hues are already theme-invariant (see [AppColors]).
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
    final tokens = context.colors;
    final isDark = context.isDarkMode;
    final effectiveBg = backgroundColor ??
        (isDark ? tokens.surface.withValues(alpha: 0.55) : tokens.surface.withValues(alpha: 0.94));
    final effectiveBorder = borderColor ??
        (isDark ? AppColors.goldenBorder.withValues(alpha: 0.5) : tokens.border);
    // Dark theme leans on the glowing border for depth; Light theme has no
    // glow to rely on, so it gets a soft, barely-there elevation shadow
    // instead (brief: "extremely soft shadows", not heavy card shadows).
    final effectiveShadow = boxShadow ??
        (isDark
            ? null
            : [
                BoxShadow(
                  color: tokens.shadow,
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ]);
    final radius = BorderRadius.circular(borderRadius);

    // The shadow lives on an outer, unclipped Container — nesting it inside
    // the ClipRRect below (as the blurred Container's own decoration) would
    // clip it away entirely, since ClipRRect clips strictly to its bounds.
    final inner = Container(
      decoration: BoxDecoration(borderRadius: radius, boxShadow: effectiveShadow),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: effectiveBg,
              borderRadius: radius,
              border: Border.all(color: effectiveBorder, width: borderWidth),
            ),
            child: child,
          ),
        ),
      ),
    );

    if (margin != null) {
      return Container(margin: margin, child: inner);
    }
    return inner;
  }
}
