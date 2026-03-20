import 'package:flutter_test/flutter_test.dart';
import 'package:petapp_mobile/core/constants/app_strings.dart';
import 'package:petapp_mobile/core/utils/translator.dart';

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

    test('returns key itself if language is unsupported', () {
      Translator.currentLanguage = 'es';
      expect(Translator.translate(AppStrings.welcomeBack), AppStrings.welcomeBack);
    });

    test('returns key itself if translation for key is missing', () {
      expect(Translator.translate('unknownKey'), 'unknownKey');
    });
  });
}
