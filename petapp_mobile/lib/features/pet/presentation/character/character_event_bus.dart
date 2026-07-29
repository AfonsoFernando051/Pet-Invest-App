import 'dart:async';

import 'package:petapp_mobile/features/pet/domain/character/character_event.dart';

/// Event Reaction Engine backbone: a lightweight in-process broadcast stream
/// of [CharacterEvent]s. Deliberately not a message broker or event-sourcing
/// store — just a `StreamController`, matching the app's existing "no new
/// infra" convention (see docs/AI_RULES.md) and the accelerometer stream
/// already used by `PetShowcase`.
class CharacterEventBus {
  final StreamController<CharacterEvent> _controller =
      StreamController<CharacterEvent>.broadcast();

  Stream<CharacterEvent> get events => _controller.stream;

  void publish(CharacterEvent event) {
    if (_controller.isClosed) return;
    _controller.add(event);
  }

  void dispose() {
    _controller.close();
  }
}
