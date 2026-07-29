import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:petapp_mobile/features/pet/domain/enums/accessory_type.dart';
import 'package:petapp_mobile/features/pet/domain/enums/idle_variant.dart';
import 'package:petapp_mobile/features/pet/domain/enums/pet_accessory_id.dart';
import 'package:petapp_mobile/features/pet/domain/enums/pet_animation_state.dart';
import 'package:petapp_mobile/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petapp_mobile/features/pet/presentation/character/character_engine.dart';
import 'package:petapp_mobile/features/pet/presentation/character/widgets/character_speech_bubble.dart';

const Duration _kBaseBreatheDuration = Duration(milliseconds: 2500);

/// Renders the gamified pet mascot: an aura layer (tinted by the Character
/// Engine's current emotion), the base evolution animation (Lottie, falling
/// back to a static PNG per stage), any equipped accessories, and a
/// transient speech bubble. Idle micro-motion (tilt) varies with
/// `CharacterEngine.idle.variant` so the mascot never sits in one static
/// loop. Tapping/petting plays a brief `happy` reaction with haptics.
class PetMascotWidget extends StatefulWidget {
  const PetMascotWidget({
    super.key,
    required this.controller,
    this.size = 220,
  });

  final CharacterEngine controller;
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
      duration: _kBaseBreatheDuration,
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

    _syncBreatheSpeed();
  }

  @override
  void didUpdateWidget(covariant PetMascotWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
      _syncBreatheSpeed();
    }
  }

  void _onControllerChanged() {
    _syncBreatheSpeed();
    setState(() {});
  }

  /// The breathe cycle's *speed* (not amplitude) reflects the current
  /// emotion — calmer emotions breathe slower, excited/celebrating ones
  /// faster — using the same Lottie/PNG art, no new assets.
  void _syncBreatheSpeed() {
    final multiplier = widget.controller.emotion.visualProfile.breatheSpeedMultiplier;
    final targetMs = (_kBaseBreatheDuration.inMilliseconds / multiplier).round();
    final targetDuration = Duration(milliseconds: targetMs);
    if (_breatheController.duration == targetDuration) return;
    _breatheController.duration = targetDuration;
    if (_breatheController.isAnimating) {
      _breatheController.repeat(reverse: true);
    }
  }

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
    final emotionProfile = widget.controller.emotion.visualProfile;

    return GestureDetector(
      onTap: _handlePet,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CharacterSpeechBubble(line: widget.controller.currentLine),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: Listenable.merge([_breatheController, _bumpController]),
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  0,
                  _bumpAnimation.value * emotionProfile.bumpIntensityMultiplier,
                ),
                child: Transform.scale(
                  scale: _breatheAnimation.value,
                  child: child,
                ),
              );
            },
            child: AnimatedRotation(
              turns: _idleTiltFor(widget.controller.idle.variant),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeInOut,
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    if (_showsAura(profile.stage, profile.animationState, emotionProfile.sparkle))
                      _AuraLayer(color: emotionProfile.auraColor, size: widget.size),
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
          ),
        ],
      ),
    );
  }

  bool _showsAura(PetEvolutionStage stage, PetAnimationState state, bool sparkle) {
    return stage.hasAura ||
        state == PetAnimationState.celebrate ||
        state == PetAnimationState.victory ||
        sparkle;
  }

  /// A small, smoothly-animated tilt per idle variant — enough to read as
  /// "looking around" / "stretching" / etc. without needing per-variant art.
  double _idleTiltFor(IdleVariant variant) {
    switch (variant) {
      case IdleVariant.breathing:
        return 0.0;
      case IdleVariant.lookAround:
        return 0.045;
      case IdleVariant.stretch:
        return -0.05;
      case IdleVariant.tailWag:
        return 0.03;
      case IdleVariant.sit:
        return 0.0;
      case IdleVariant.watchCoins:
        return 0.035;
      case IdleVariant.watchNotification:
        return -0.03;
    }
  }
}

class _AuraLayer extends StatelessWidget {
  const _AuraLayer({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
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
        'assets/images/generated_dog.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.pets,
          size: size * 0.6,
          color: Colors.white70,
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
