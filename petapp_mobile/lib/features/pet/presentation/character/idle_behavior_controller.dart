import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:petapp_mobile/features/pet/domain/enums/idle_variant.dart';
import 'package:petapp_mobile/features/pet/domain/enums/pet_animation_state.dart';

/// Behavior Controller subsystem: the pet "must never remain static" idle
/// system. While (and only while) the mascot's top-level [PetAnimationState]
/// is `idle`, this picks a new random [IdleVariant] every [minInterval]–
/// [maxInterval] so the same idle clip reads as breathing/looking around/
/// stretching/etc. rather than one static loop. Freezes as soon as an event
/// animation (celebrate, sleep, victory...) takes over, and resumes cycling
/// when the mascot returns to idle.
class IdleBehaviorController extends ChangeNotifier {
  IdleBehaviorController({
    math.Random? random,
    this.minInterval = const Duration(seconds: 4),
    this.maxInterval = const Duration(seconds: 10),
  }) : _random = random ?? math.Random();

  final math.Random _random;
  final Duration minInterval;
  final Duration maxInterval;

  Timer? _timer;
  IdleVariant _variant = IdleVariant.breathing;
  bool _isIdle = true;

  IdleVariant get variant => _variant;

  /// Starts the idle cycle. Call once the mascot profile has loaded.
  void start() {
    _isIdle = true;
    _scheduleNext();
  }

  /// Feed every `MascotController` animation-state change here so idle
  /// variants only cycle while the mascot is actually idle.
  void onAnimationStateChanged(PetAnimationState state) {
    final idleNow = state == PetAnimationState.idle;
    if (idleNow == _isIdle) return;
    _isIdle = idleNow;
    if (_isIdle) {
      _scheduleNext();
    } else {
      _timer?.cancel();
    }
  }

  void _scheduleNext() {
    _timer?.cancel();
    _timer = Timer(_randomInterval(), _pickNext);
  }

  Duration _randomInterval() {
    final spanMs = maxInterval.inMilliseconds - minInterval.inMilliseconds;
    if (spanMs <= 0) return minInterval;
    return minInterval + Duration(milliseconds: _random.nextInt(spanMs + 1));
  }

  void _pickNext() {
    if (!_isIdle) return;
    final options = IdleVariant.values.where((v) => v != _variant).toList();
    _variant = options[_random.nextInt(options.length)];
    notifyListeners();
    _scheduleNext();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
