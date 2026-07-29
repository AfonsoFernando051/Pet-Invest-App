import 'package:flutter_test/flutter_test.dart';
import 'package:petapp_mobile/features/pet/presentation/character/relationship_engine.dart';

void main() {
  group('RelationshipEngine.evaluate', () {
    const engine = RelationshipEngine();
    final now = DateTime(2026, 7, 29, 10);

    test('less than a day away is not a welcome-back moment', () {
      final moment = engine.evaluate(
        lastActiveAt: now.subtract(const Duration(hours: 5)),
        now: now,
      );

      expect(moment.type, RelationshipMomentType.none);
    });

    test('exactly one day away is a welcome-back moment', () {
      final moment = engine.evaluate(
        lastActiveAt: now.subtract(const Duration(days: 1)),
        now: now,
      );

      expect(moment.type, RelationshipMomentType.welcomeBack);
      expect(moment.daysAway, 1);
    });

    test('several days away reports the correct day count', () {
      final moment = engine.evaluate(
        lastActiveAt: now.subtract(const Duration(days: 5)),
        now: now,
      );

      expect(moment.type, RelationshipMomentType.welcomeBack);
      expect(moment.daysAway, 5);
    });
  });
}
