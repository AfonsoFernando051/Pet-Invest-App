import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/utils/translator.dart';

void main() {
  setUp(() {
    Translator.currentLanguage = 'pt';
  });

  group('Translator', () {
    test('translates key to Portuguese by default', () {
      expect(Translator.translate(AppStrings.welcomeBack), "Bem-vindo de volta");
    });

    test('translates key to English when language changes', () {
      Translator.currentLanguage = 'en';
      expect(Translator.translate(AppStrings.welcomeBack), "Welcome back");
    });

    test('translates key to Spanish when language changes', () {
      Translator.currentLanguage = 'es';
      expect(Translator.translate(AppStrings.welcomeBack), "Bienvenido de nuevo");
    });

    test('falls back to default language if language is unsupported', () {
      Translator.currentLanguage = 'fr';
      expect(Translator.translate(AppStrings.welcomeBack), "Bem-vindo de volta");
    });

    test('returns key itself if translation for key is missing', () {
      expect(Translator.translate('unknownKey'), 'unknownKey');
    });
  });
}
