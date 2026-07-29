import 'dart:math';
import 'package:flutter/material.dart';

/// The app's shared space background: the nebula image with a slow Ken-Burns
/// drift, a subtle desaturation/darken pass so foreground content reads with
/// more contrast, and a twinkling starfield layered on top for ambient life.
///
/// Centralizing this (previously a single static `Image.asset` inlined in
/// `DashboardScreen._buildBackground`) means every screen that adopts it
/// gets the same living-background treatment for free.
class CosmicBackground extends StatefulWidget {
  const CosmicBackground({
    super.key,
    required this.child,
    this.assetPath = 'assets/images/bg_nebula.png',
    this.darken = 0.5,
    this.starCount = 46,
    this.errorBuilder,
  });

  final Widget child;
  final String assetPath;

  /// 0-1 black overlay strength on top of the (already desaturated) nebula.
  final double darken;
  final int starCount;
  final ImageErrorWidgetBuilder? errorBuilder;

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
