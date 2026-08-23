import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import 'package:petrimonium/features/pet/domain/enums/pet_animation_state.dart';

/// Convention: each `.riv` pet file must have a state machine named
/// [kPetStateMachine] and one **trigger input** per animation state
/// (named exactly as [PetAnimationState.name], e.g. `"idle"`, `"celebrate"`).
///
/// File naming:   `assets/mascot/rive/{specie}.riv`
///   e.g.  `assets/mascot/rive/dog.riv`
///
/// When no `.riv` file exists for the species, [onFallback] is called
/// so the parent widget renders the Lottie / PNG fallback instead.
const String kPetStateMachine = 'PetController';

/// A widget that loads a species-specific `.riv` file and drives its state
/// machine via trigger inputs matching [PetAnimationState] names.
///
/// This is the highest-priority layer in the mascot fallback chain:
///   1. **Rive**  `assets/mascot/rive/{specie}.riv`   ← this widget
///   2. Lottie   `assets/mascot/animations/{specie}_{state}.json`
///   3. Lottie   `assets/mascot/animations/{state}.json`
///   4. PNG      `assets/mascot/evolutions/{stage}.png`
class RivePetLayer extends StatefulWidget {
  const RivePetLayer({
    super.key,
    required this.specie,
    required this.state,
    required this.size,
    required this.onFallback,
  });

  /// Lowercase species name, e.g. `"dog"`, `"fox"`.
  final String specie;

  /// Current animation state — fires the matching trigger in the state machine.
  final PetAnimationState state;

  final double size;

  /// Called when the `.riv` asset cannot be loaded or has no valid state
  /// machine, so the parent can render the Lottie / PNG fallback instead.
  final WidgetBuilder onFallback;

  @override
  State<RivePetLayer> createState() => _RivePetLayerState();
}

class _RivePetLayerState extends State<RivePetLayer> {
  /// Null = loading, true = riv OK, false = fallback.
  bool? _available;

  RiveWidgetController? _controller;
  StateMachine? _sm;
  FileLoader? _loader;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didUpdateWidget(covariant RivePetLayer old) {
    super.didUpdateWidget(old);
    if (old.specie != widget.specie) {
      _disposeController();
      setState(() => _available = null);
      _init();
    } else if (old.state != widget.state && _available == true) {
      _fireState(widget.state);
    }
  }

  String get _assetPath => 'assets/mascot/rive/${widget.specie}.riv';

  void _init() {
    _loader = FileLoader.fromAsset(
      _assetPath,
      riveFactory: Factory.rive,
    );
  }

  void _onRiveLoaded(RiveLoaded loaded) {
    _controller = loaded.controller;
    _sm = _controller?.stateMachine;
    _fireState(widget.state);
    if (mounted) setState(() => _available = true);
  }

  void _onRiveFailed(Object err, StackTrace st) {
    if (mounted) setState(() => _available = false);
  }

  void _fireState(PetAnimationState state) {
    // Trigger inputs are the stable code-driven way to control state machines
    // in Rive 0.14. The deprecation notice points to Data Binding (editor-only
    // workflow) which is not applicable for runtime-driven state changes.
    _sm?.trigger(state.name)?.fire(); // ignore: deprecated_member_use
  }

  void _disposeController() {
    _controller?.dispose();
    _controller = null;
    _sm = null;
    _loader = null;
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final available = _available;

    // Show nothing (transparent) while the async load resolves.
    if (available == null) {
      return _buildBuilder();
    }

    if (available == false) {
      return widget.onFallback(context);
    }

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: RiveWidget(
        controller: _controller!,
        fit: Fit.contain,
      ),
    );
  }

  /// Builds the async loader which populates [_available].
  Widget _buildBuilder() {
    if (_loader == null) return widget.onFallback(context);
    return RiveWidgetBuilder(
      fileLoader: _loader!,
      stateMachineSelector: StateMachineSelector.byName(kPetStateMachine),
      onLoaded: _onRiveLoaded,
      onFailed: _onRiveFailed,
      builder: (context, state) {
        if (state is RiveLoading) {
          // Transparent placeholder — no layout jump.
          return SizedBox(width: widget.size, height: widget.size);
        }
        if (state is RiveFailed) {
          return widget.onFallback(context);
        }
        // RiveLoaded: widget will be updated via setState in onLoaded.
        return SizedBox(width: widget.size, height: widget.size);
      },
    );
  }
}
