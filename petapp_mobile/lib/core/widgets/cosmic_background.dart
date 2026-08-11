import 'dart:math';
import 'package:flutter/material.dart';
import 'package:petapp_mobile/core/constants/app_colors.dart';
import 'package:petapp_mobile/core/theme/app_color_tokens.dart';

/// The app's shared "living background". In Dark theme this is the original
/// nebula image with a slow Ken-Burns drift, a darken pass, and a twinkling
/// starfield. Light theme swaps the space imagery for a soft, bright aurora
/// gradient with slow-drifting color blobs — same "alive, not static
/// wallpaper" feeling, without forcing a dark space scene onto a bright,
/// friendly theme. One widget, two looks — no duplicated screens.
class CosmicBackground extends StatefulWidget {
  const CosmicBackground({
    super.key,
    required this.child,
    this.assetPath = 'assets/images/bg_nebula.png',
    this.darken = 0.5,
    this.starCount = 46,
    this.errorBuilder,
    this.showArtworkInLightMode = false,
  });

  final Widget child;
  final String assetPath;

  /// 0-1 black overlay strength on top of the (already desaturated) nebula.
  /// Dark theme only.
  final double darken;
  final int starCount;
  final ImageErrorWidgetBuilder? errorBuilder;

  /// When true, Light theme reuses [assetPath] (with a lightened, white-wash
  /// treatment) instead of the generic abstract aurora — for screens like
  /// Login where the artwork itself (not just ambient color) is the point.
  /// Defaults to false: most `CosmicBackground` call sites use the generic
  /// dark-space `bg_nebula.png`, which reads as heavy even lightened, so
  /// they keep the abstract aurora treatment instead.
  final bool showArtworkInLightMode;

  @override
  State<CosmicBackground> createState() => _CosmicBackgroundState();
}

class _CosmicBackgroundState extends State<CosmicBackground> with TickerProviderStateMixin {
  late final AnimationController _driftController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 26),
  )..repeat();

  late final AnimationController _twinkleController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  )..repeat();

  late final List<_Star> _stars = _generateStars(widget.starCount);

  static List<_Star> _generateStars(int count) {
    final random = Random(7); // fixed seed: stable layout across rebuilds
    return List.generate(count, (_) {
      return _Star(
        dx: random.nextDouble(),
        dy: random.nextDouble(),
        radius: 0.6 + random.nextDouble() * 1.4,
        phase: random.nextDouble(),
        speed: 0.6 + random.nextDouble() * 0.8,
      );
    });
  }

  @override
  void dispose() {
    _driftController.dispose();
    _twinkleController.dispose();
    super.dispose();
  }

  // Reduces color saturation by [amount] (0 = no change, 1 = grayscale) so
  // the background never competes with foreground glass cards for attention.
  static List<double> _desaturationMatrix(double amount) {
    const lumR = 0.2126, lumG = 0.7152, lumB = 0.0722;
    final s = 1 - amount;
    final sr = (1 - s) * lumR;
    final sg = (1 - s) * lumG;
    final sb = (1 - s) * lumB;
    return <double>[
      sr + s, sg, sb, 0, 0,
      sr, sg + s, sb, 0, 0,
      sr, sg, sb + s, 0, 0,
      0, 0, 0, 1, 0,
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (!context.isDarkMode) {
      if (widget.showArtworkInLightMode) {
        return _LightImageBackground(
          driftController: _driftController,
          assetPath: widget.assetPath,
          errorBuilder: widget.errorBuilder,
          child: widget.child,
        );
      }
      return _LightAuroraBackground(driftController: _driftController, child: widget.child);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedBuilder(
          animation: _driftController,
          builder: (context, child) {
            // Slow figure-eight-ish pan/scale — a Ken-Burns drift subtle
            // enough to read as "alive" without ever being distracting.
            final t = _driftController.value * 2 * pi;
            final dx = sin(t) * 10;
            final dy = cos(t * 0.7) * 6;
            return Transform.scale(
              scale: 1.06,
              child: Transform.translate(offset: Offset(dx, dy), child: child),
            );
          },
          child: ColorFiltered(
            colorFilter: ColorFilter.matrix(_desaturationMatrix(0.2)),
            child: Image.asset(widget.assetPath, fit: BoxFit.cover, errorBuilder: widget.errorBuilder),
          ),
        ),
        Container(color: Colors.black.withValues(alpha: widget.darken)),
        AnimatedBuilder(
          animation: _twinkleController,
          builder: (context, _) => CustomPaint(
            painter: _StarfieldPainter(stars: _stars, t: _twinkleController.value),
          ),
        ),
        widget.child,
      ],
    );
  }
}

/// Light theme's answer to the nebula: a soft pearl/lavender gradient with
/// two or three large, heavily-blurred accent-tinted blobs drifting slowly
/// behind the content — "bright and alive", not "dark space scene lightened
/// up". Built from plain gradients (no BackdropFilter/blur passes) so it
/// stays cheap to repaint every frame.
class _LightAuroraBackground extends StatelessWidget {
  const _LightAuroraBackground({required this.driftController, required this.child});

  final AnimationController driftController;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [tokens.backgroundPrimary, tokens.backgroundSecondary],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: driftController,
          builder: (context, _) {
            final t = driftController.value * 2 * pi;
            return CustomPaint(
              painter: _AuroraPainter(
                t: t,
                colors: [
                  AppColors.neonCyan.withValues(alpha: 0.10),
                  AppColors.neonPurple.withValues(alpha: 0.09),
                  AppColors.goldenBorder.withValues(alpha: 0.06),
                ],
              ),
            );
          },
        ),
        child,
      ],
    );
  }
}

/// Light-theme treatment for screens that want their own artwork as ambient
/// wallpaper (e.g. Login's fox-and-compass illustration) rather than the
/// generic aurora — same Ken-Burns drift as Dark theme's nebula, but a soft
/// white wash instead of a black darken pass, so the art reads as bright and
/// dreamy instead of heavy. No starfield: white twinkles would disappear
/// against a light wash.
class _LightImageBackground extends StatelessWidget {
  const _LightImageBackground({
    required this.driftController,
    required this.assetPath,
    required this.child,
    this.errorBuilder,
  });

  final AnimationController driftController;
  final String assetPath;
  final Widget child;
  final ImageErrorWidgetBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: tokens.backgroundPrimary),
        AnimatedBuilder(
          animation: driftController,
          builder: (context, child) {
            final t = driftController.value * 2 * pi;
            final dx = sin(t) * 10;
            final dy = cos(t * 0.7) * 6;
            return Transform.scale(
              scale: 1.06,
              child: Transform.translate(offset: Offset(dx, dy), child: child),
            );
          },
          child: ColorFiltered(
            colorFilter: ColorFilter.matrix(_CosmicBackgroundState._desaturationMatrix(0.08)),
            child: Image.asset(assetPath, fit: BoxFit.cover, errorBuilder: errorBuilder),
          ),
        ),
        Container(color: tokens.backgroundPrimary.withValues(alpha: 0.62)),
        child,
      ],
    );
  }
}

class _AuroraPainter extends CustomPainter {
  _AuroraPainter({required this.t, required this.colors});

  final double t;
  final List<Color> colors;

  static const List<Offset> _anchors = [Offset(0.15, 0.12), Offset(0.85, 0.28), Offset(0.35, 0.85)];

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < _anchors.length; i++) {
      final anchor = _anchors[i];
      final phase = t + i * (2 * pi / _anchors.length);
      final dx = anchor.dx * size.width + sin(phase) * size.width * 0.06;
      final dy = anchor.dy * size.height + cos(phase * 0.8) * size.height * 0.05;
      final radius = size.shortestSide * 0.42;
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [colors[i % colors.length], colors[i % colors.length].withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: Offset(dx, dy), radius: radius));
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter oldDelegate) => oldDelegate.t != t;
}

class _Star {
  const _Star({required this.dx, required this.dy, required this.radius, required this.phase, required this.speed});

  final double dx;
  final double dy;
  final double radius;
  final double phase;
  final double speed;
}

class _StarfieldPainter extends CustomPainter {
  _StarfieldPainter({required this.stars, required this.t});

  final List<_Star> stars;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final star in stars) {
      final cycle = (t * star.speed + star.phase) % 1.0;
      final twinkle = (sin(cycle * 2 * pi) + 1) / 2; // 0..1
      final opacity = 0.15 + twinkle * 0.55;
      paint.color = Colors.white.withValues(alpha: opacity);
      canvas.drawCircle(Offset(star.dx * size.width, star.dy * size.height), star.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarfieldPainter oldDelegate) => oldDelegate.t != t;
}
