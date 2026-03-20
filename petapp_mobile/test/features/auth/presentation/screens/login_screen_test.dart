import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petapp_mobile/core/utils/translator.dart';
import 'package:petapp_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:petapp_mobile/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:petapp_mobile/features/auth/presentation/widgets/login_background.dart';
import 'package:petapp_mobile/features/auth/presentation/widgets/login_button.dart';
import 'package:petapp_mobile/features/auth/presentation/widgets/login_card.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  Widget buildTestableWidget() {
    return const MaterialApp(
      home: LoginScreen(),
    );
  }

  group('LoginScreen', () {
    testWidgets('renders perfectly with all child components', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(find.byType(LoginCard), findsOneWidget);
      expect(find.byType(LoginBackground), findsOneWidget);
      expect(find.byType(CustomTextField), findsNWidgets(2));
      expect(find.byType(LoginButton), findsOneWidget);

      expect(find.text('Bem-vindo de volta'), findsOneWidget);
      expect(find.text('E-mail ou Usuário'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);
    });

    testWidgets('updates UI text when Translator language changes', (WidgetTester tester) async {
      Translator.currentLanguage = 'en';
      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Email or Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);

      expect(find.text('Bem-vindo de volta'), findsNothing);
    });

    testWidgets('TextFields accept text input properly', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());

      final emailField = find.descendant(
        of: find.byType(CustomTextField),
        matching: find.byType(TextField),
      ).first;

      await tester.enterText(emailField, 'test@example.com');
      await tester.pump();

      expect(find.text('test@example.com'), findsOneWidget);
    });
  });
}
