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
      AppStrings.createAccount: "Criar Conta",
      AppStrings.fillDetails: "Preencha seus dados",
      AppStrings.nameHint: "Nome Completo",
      AppStrings.confirmPasswordHint: "Confirmar Senha",
      AppStrings.signupButton: "Cadastrar",
      AppStrings.alreadyHaveAccount: "Já tem conta? Entrar",
    },
    'en': {
      AppStrings.welcomeBack: "Welcome back",
      AppStrings.loginToContinue: "Login to continue",
      AppStrings.emailOrUserHint: "Email or Username",
      AppStrings.passwordHint: "Password",
      AppStrings.forgotPassword: "Forgot password?",
      AppStrings.noAccountSignUp: "Don't have an account? Sign up",
      AppStrings.loginButton: "Login",
      AppStrings.createAccount: "Create Account",
      AppStrings.fillDetails: "Fill in your details",
      AppStrings.nameHint: "Full Name",
      AppStrings.confirmPasswordHint: "Confirm Password",
      AppStrings.signupButton: "Sign Up",
      AppStrings.alreadyHaveAccount: "Already have an account? Login",
    },
  };

  static String translate(String key) {
    return _localizedValues[currentLanguage]?[key] ?? key;
  }
}
