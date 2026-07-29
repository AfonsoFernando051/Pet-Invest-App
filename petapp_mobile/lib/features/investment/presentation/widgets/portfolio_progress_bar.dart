import 'package:flutter/material.dart';
import 'package:petapp_mobile/core/constants/app_colors.dart';

/// Reframes "fill out a form" as visible onboarding progress toward a
/// starter-portfolio milestone ([target] assets) — there's no fixed step
/// count in this flow (the user repeats one form N times), so progress is
/// tied to the same asset-count milestone the CTA button and rewards
/// checklist react to, rather than an arbitrary wizard step.
class PortfolioProgressBar extends StatelessWidget {
  const PortfolioProgressBar({super.key, required this.assetCount, this.target = 3});

  final int assetCount;
  final int target;

  @override
  Widget build(BuildContext context) {
    final progress = (assetCount / target).clamp(0.0, 1.0);
    final isComplete = assetCount >= target;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                isComplete ? 'Portfólio Inicial Completo ✓' : 'Progresso do Portfólio Inicial',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isComplete ? AppColors.positiveGreen : AppColors.subtleText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                color: isComplete ? AppColors.positiveGreen : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            children: [
              Container(height: 8, color: Colors.white.withValues(alpha: 0.08)),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => FractionallySizedBox(
                  widthFactor: value,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isComplete
                            ? [AppColors.positiveGreen, AppColors.neonCyan]
                            : [AppColors.neonViolet, AppColors.neonCyan],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
