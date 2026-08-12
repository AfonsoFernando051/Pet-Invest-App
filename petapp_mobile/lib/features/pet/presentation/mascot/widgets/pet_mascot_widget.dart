import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/pet_assets.dart';
import 'package:petrimonium/features/pet/domain/enums/accessory_type.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_accessory_id.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_animation_state.dart';
import 'package:petrimonium/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petrimonium/features/pet/presentation/mascot/controllers/mascot_controller.dart';

/// Renders the gamified pet mascot: an aura layer, the base evolution
/// animation (Lottie, falling back to a static PNG per stage), and any
/// equipped accessories layered on top. Tapping/petting the mascot plays a
/// brief `happy` reaction with light haptic feedback.
class PetMascotWidget extends StatefulWidget {
  const PetMascotWidget({
    super.key,
    required this.controller,
    this.size = 220,
  });

  final MascotController controller;
  final double size;

  @override
  State<PetMascotWidget> createState() => _PetMascotWidgetState();
}

class _PetMascotWidgetState extends State<PetMascotWidget>
    with TickerProviderStateMixin {
  late final AnimationController _breatheController;
  late final Animation<double> _breatheAnimation;

  late final AnimationController _bumpController;
  late final Animation<double> _bumpAnimation;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);

    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
    _breatheAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOutSine),
    );

    _bumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bumpAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -18).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -18, end: 0).chain(CurveTween(curve: Curves.bounceOut)),
        weight: 50,
      ),
    ]).animate(_bumpController);
  }

  @override
  void didUpdateWidget(covariant PetMascotWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  void _onControllerChanged() => setState(() {});

  void _handlePet() {
    HapticFeedback.lightImpact();
    if (!_bumpController.isAnimating) _bumpController.forward(from: 0);
    widget.controller.triggerEventAnimation(
      PetAnimationState.happy,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _breatheController.dispose();
    _bumpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.controller.profile;

    return GestureDetector(
      onTap: _handlePet,
      child: AnimatedBuilder(
        animation: Listenable.merge([_breatheController, _bumpController]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _bumpAnimation.value),
            child: Transform.scale(
              scale: _breatheAnimation.value,
              child: child,
            ),
          );
        },
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (_showsAura(profile.stage, profile.animationState))
                _AuraLayer(stage: profile.stage, size: widget.size),
              _BaseMascotLayer(
                state: profile.animationState,
                stage: profile.stage,
                size: widget.size,
              ),
              for (final entry in profile.equippedAccessories.entries)
                _AccessoryLayer(
                  slot: entry.key,
                  accessoryId: entry.value,
                  size: widget.size,
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool _showsAura(PetEvolutionStage stage, PetAnimationState state) {
    return stage.hasAura ||
        state == PetAnimationState.celebrate ||
        state == PetAnimationState.victory;
  }
}

class _AuraLayer extends StatelessWidget {
  const _AuraLayer({required this.stage, required this.size});

  final PetEvolutionStage stage;
  final double size;

  Color get _color {
    if (stage.tier >= 9) return AppColors.goldenBorder;
    if (stage.tier >= 8) return AppColors.neonPurple;
    if (stage.tier >= 7) return AppColors.neonCyan;
    if (stage.tier >= 6) return AppColors.neonViolet;
    return AppColors.neonCyan;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _color.withValues(alpha: 0.35),
            blurRadius: size * 0.25,
            spreadRadius: size * 0.05,
          ),
        ],
      ),
    );
  }
}

class _BaseMascotLayer extends StatelessWidget {
  const _BaseMascotLayer({
    required this.state,
    required this.stage,
    required this.size,
  });

  final PetAnimationState state;
  final PetEvolutionStage stage;
  final double size;

  @override
  Widget build(BuildContext context) {
    final mascotSize = size * 0.9;
    return Lottie.asset(
      'assets/mascot/animations/${state.assetKey}.json',
      width: mascotSize,
      height: mascotSize,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => _EvolutionFallback(
        stage: stage,
        size: mascotSize,
      ),
    );
  }
}

/// Static PNG fallback for a given evolution [stage], used while
/// per-state Lottie animations aren't authored yet.
class _EvolutionFallback extends StatelessWidget {
  const _EvolutionFallback({required this.stage, required this.size});

  final PetEvolutionStage stage;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/mascot/evolutions/${stage.assetKey}.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Image.asset(
        PetAssets.imageFor(null),
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.pets,
          size: size * 0.6,
          color: context.colors.textSecondary,
        ),
      ),
    );
  }
}

class _AccessoryLayer extends StatelessWidget {
  const _AccessoryLayer({
    required this.slot,
    required this.accessoryId,
    required this.size,
  });

  final AccessoryType slot;
  final PetAccessoryId accessoryId;
  final double size;

  Alignment get _alignment {
    switch (slot) {
      case AccessoryType.headwear:
        return const Alignment(0, -0.85);
      case AccessoryType.eyewear:
        return const Alignment(0, -0.25);
      case AccessoryType.neckBack:
        return const Alignment(0, 0.4);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _alignment,
      child: Image.asset(
        'assets/mascot/accessories/${accessoryId.assetKey}.png',
        width: size * 0.5,
        fit: BoxFit.contain,
        // Accessory art is opt-in and may not exist yet; render nothing
        // rather than a broken-image icon.
        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
      ),
    );
  }
}
