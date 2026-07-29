import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:petapp_mobile/features/pet/data/models/pet_specie_enum.dart';
import 'package:petapp_mobile/features/pet/domain/enums/accessory_type.dart';
import 'package:petapp_mobile/features/pet/domain/enums/character_emotion.dart';
import 'package:petapp_mobile/features/pet/domain/enums/idle_variant.dart';
import 'package:petapp_mobile/features/pet/domain/enums/pet_accessory_id.dart';
import 'package:petapp_mobile/features/pet/domain/enums/pet_animation_state.dart';
import 'package:petapp_mobile/features/pet/domain/enums/pet_evolution_stage.dart';
import 'package:petapp_mobile/features/pet/presentation/character/asset/character_asset_loader.dart';
import 'package:petapp_mobile/features/pet/presentation/character/character_engine.dart';
import 'package:petapp_mobile/features/pet/presentation/character/widgets/character_speech_bubble.dart';

const Duration _kBaseBreatheDuration = Duration(milliseconds: 2500);
const Duration _kPoseCrossfadeDuration = Duration(milliseconds: 250);
const CharacterAssetLoader _kAssetLoader = CharacterAssetLoader();

/// Renders the living character: an aura layer (tinted by the current
/// emotion), the base pose animation — species-specific Lottie once one
/// exists (`CharacterAssetLoader`), falling back through the shared Lottie
/// clip, the evolution-stage PNG, a generic PNG, and finally an icon — any
/// equipped accessories, an (currently empty, art-pending) expression
/// overlay, and a transient speech bubble. Idle micro-motion (tilt) varies
/// with `CharacterEngine.idle.variant`. Tap/double-tap/long-press/drag all
/// route through `CharacterEngine.interaction` — this widget never mutates
/// animation/emotion state itself.
class CharacterWidget extends StatefulWidget {
  const CharacterWidget({
    super.key,
    required this.controller,
    this.size = 220,
  });

  final CharacterEngine controller;
  final double size;

  @override
  State<CharacterWidget> createState() => _CharacterWidgetState();
}

class _CharacterWidgetState extends State<CharacterWidget>
    with TickerProviderStateMixin {
  late final AnimationController _breatheController;
  late final Animation<double> _breatheAnimation;

  late final AnimationController _bumpController;
  late final Animation<double> _bumpAnimation;

  late final AnimationController _dragBackController;
  Offset _dragOffset = Offset.zero;
  Animation<Offset>? _dragSpringBack;

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

    _dragBackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..addListener(() {
        final springBack = _dragSpringBack;
        if (springBack == null) return;
        setState(() => _dragOffset = springBack.value);
      });

    _syncBreatheSpeed();
  }

  @override
  void didUpdateWidget(covariant CharacterWidget oldWidget) {
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

  void _handleTap() {
    HapticFeedback.lightImpact();
    if (!_bumpController.isAnimating) _bumpController.forward(from: 0);
    widget.controller.interaction.onTap();
  }

  void _handleDoubleTap() {
    HapticFeedback.mediumImpact();
    widget.controller.interaction.onDoubleTap();
  }

  void _handleLongPress() {
    HapticFeedback.selectionClick();
    widget.controller.interaction.onLongPress();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    _dragBackController.stop();
    setState(() {
      _dragOffset += details.delta;
      final maxRadius = widget.size * 0.35;
      if (_dragOffset.distance > maxRadius) {
        _dragOffset = Offset.fromDirection(_dragOffset.direction, maxRadius);
      }
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    _dragSpringBack = Tween<Offset>(begin: _dragOffset, end: Offset.zero).animate(
      CurvedAnimation(parent: _dragBackController, curve: Curves.elasticOut),
    );
    _dragBackController.forward(from: 0);
    widget.controller.interaction.onDragReleased();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _breatheController.dispose();
    _bumpController.dispose();
    _dragBackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.controller.profile;
    final emotionProfile = widget.controller.emotion.visualProfile;

    return GestureDetector(
      onTap: _handleTap,
      onDoubleTap: _handleDoubleTap,
      onLongPress: _handleLongPress,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
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
                  _dragOffset.dx,
                  _dragOffset.dy + _bumpAnimation.value * emotionProfile.bumpIntensityMultiplier,
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
                    AnimatedSwitcher(
                      duration: _kPoseCrossfadeDuration,
                      child: _BaseMascotLayer(
                        key: ValueKey(profile.animationState),
                        species: profile.specie,
                        state: profile.animationState,
                        stage: profile.stage,
                        size: widget.size,
                      ),
                    ),
                    _ExpressionLayer(
                      species: profile.specie,
                      emotion: widget.controller.emotion.emotion,
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
  /// "stretching" / "looking up" / "waving" / etc. without needing the
  /// per-variant art each name refers to in `assets/pets/*.png` yet.
  double _idleTiltFor(IdleVariant variant) {
    switch (variant) {
      case IdleVariant.breathing:
        return 0.0;
      case IdleVariant.blinking:
        return 0.0;
      case IdleVariant.stretch:
        return -0.05;
      case IdleVariant.sit:
        return 0.0;
      case IdleVariant.layDown:
        return -0.06;
      case IdleVariant.lookUp:
        return 0.04;
      case IdleVariant.lookDown:
        return -0.04;
      case IdleVariant.think:
        return 0.03;
      case IdleVariant.wave:
        return 0.05;
      case IdleVariant.eat:
        return -0.03;
      case IdleVariant.drink:
        return -0.02;
      case IdleVariant.dance:
        return 0.06;
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
    super.key,
    required this.species,
    required this.state,
    required this.stage,
    required this.size,
  });

  final PetSpecieEnum species;
  final PetAnimationState state;
  final PetEvolutionStage stage;
  final double size;

  @override
  Widget build(BuildContext context) {
    final mascotSize = size * 0.9;
    final candidates = _kAssetLoader.posePaths(species, state);
    return _lottieChain(candidates, 0, mascotSize);
  }

  Widget _lottieChain(List<String> paths, int index, double mascotSize) {
    if (index >= paths.length) {
      return _EvolutionFallback(stage: stage, size: mascotSize);
    }
    return Lottie.asset(
      paths[index],
      width: mascotSize,
      height: mascotSize,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => _lottieChain(paths, index + 1, mascotSize),
    );
  }
}

/// Static PNG fallback for a given evolution [stage], used while
/// per-species/per-state Lottie animations aren't authored yet.
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

/// The species-specific face for the current emotion, layered near the top
/// of the mascot. Renders nothing until the species' `expressions` folder
/// (see `CharacterAssetLoader`) actually has files — today that's every
/// species, so this is a no-op overlay, wired ahead of the art existing.
class _ExpressionLayer extends StatelessWidget {
  const _ExpressionLayer({
    required this.species,
    required this.emotion,
    required this.size,
  });

  final PetSpecieEnum species;
  final CharacterEmotion emotion;
  final double size;

  @override
  Widget build(BuildContext context) {
    final candidates = _kAssetLoader.expressionPaths(species, emotion);
    return Align(
      alignment: const Alignment(0, -0.3),
      child: _imageChain(candidates, 0),
    );
  }

  Widget _imageChain(List<String> paths, int index) {
    if (index >= paths.length) return const SizedBox.shrink();
    return Image.asset(
      paths[index],
      width: size * 0.45,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => _imageChain(paths, index + 1),
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
