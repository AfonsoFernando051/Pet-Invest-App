import '../constants/app_strings.dart';

class Translator {
  // The current language, can be updated based on user preferences or device locale
  static String currentLanguage = 'pt';

  static const Map<String, Map<String, String>> _localizedValues = {
    'pt': {
      AppStrings.welcomeBack: "Bem-vindo de volta",
      AppStrings.loginToContinue: "Faça login para continuar",
      AppStrings.emailOrUserHint: "E-mail ou Usuário",
      AppStrings.passwordHint: "Senha",
      AppStrings.forgotPassword: "Esqueceu a senha?",
      AppStrings.noAccountSignUp: "Não tem conta? Cadastre-se",
      AppStrings.loginButton: "Entrar",
    },
    'en': {
      AppStrings.welcomeBack: "Welcome back",
      AppStrings.loginToContinue: "Login to continue",
      AppStrings.emailOrUserHint: "Email or Username",
      AppStrings.passwordHint: "Password",
      AppStrings.forgotPassword: "Forgot password?",
      AppStrings.noAccountSignUp: "Don't have an account? Sign up",
      AppStrings.loginButton: "Login",
    },
  };

  static String translate(String key) {
    return _localizedValues[currentLanguage]?[key] ?? key;
  }
}
