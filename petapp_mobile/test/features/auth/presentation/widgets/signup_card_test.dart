import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petapp_mobile/core/utils/translator.dart';
import 'package:petapp_mobile/core/di/dependency_injection.dart';
import 'package:petapp_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:petapp_mobile/features/auth/presentation/widgets/signup_card.dart';
import 'package:petapp_mobile/features/auth/presentation/widgets/custom_text_field.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    Translator.currentLanguage = 'pt';
    mockAuthRepository = MockAuthRepository();
    DI.authRepository = mockAuthRepository;
  });

  Widget buildTestableWidget() {
    return const MaterialApp(
      home: Scaffold(
        body: SignupCard(),
      ),
    );
  }

  group('SignupCard', () {
    testWidgets('renders all fields and attempts registration on tap', (WidgetTester tester) async {
      when(() => mockAuthRepository.register(any(), any(), any())).thenAnswer((_) async {});
      when(() => mockAuthRepository.login(any(), any())).thenAnswer((_) async {});
      
      await tester.pumpWidget(buildTestableWidget());

      // Fields: Name, Email, Password, Confirm Password
      expect(find.byType(CustomTextField), findsNWidgets(4));

      // `CustomTextField` wraps a `TextField`, so we target the underlying `TextField`s in order.
      final textFields = find.descendant(
        of: find.byType(CustomTextField),
        matching: find.byType(TextField),
      );

      final nameField = textFields.at(0);
      final emailField = textFields.at(1);
      final passwordField = textFields.at(2);
      final confirmPasswordField = textFields.at(3);

      // Fill in the form
      await tester.enterText(nameField, 'Test User');
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.enterText(confirmPasswordField, 'password123');
      await tester.pump();

      // Tap the signup button, it should be the first ElevatedButton
      final signupBtn = find.byType(ElevatedButton).first;
      await tester.tap(signupBtn);
      
      await tester.pump(); // UI updates with loading state
      await tester.pump(); // UI updates with success snackbar

      verify(() => mockAuthRepository.register('Test User', 'test@example.com', 'password123')).called(1);
    });
  });
}
