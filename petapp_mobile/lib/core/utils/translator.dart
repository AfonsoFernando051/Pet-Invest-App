import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_strings.dart';

/// App-wide translator. pt-BR is the product's default language; en/es are
/// offered through the Settings screen. [languageNotifier] lets widgets
/// rebuild reactively when the user switches language without pulling in a
/// state-management package, matching this project's existing DI-by-static-class style.
class Translator {
  Translator._();

  static const String _prefsKey = 'app_language';
  static const String defaultLanguage = 'pt';
  static const Set<String> supportedLanguages = {'pt', 'en', 'es'};

  static final ValueNotifier<String> languageNotifier = ValueNotifier(defaultLanguage);

  static String get currentLanguage => languageNotifier.value;

  /// Synchronous setter kept for tests and simple in-memory switches.
  /// Prefer [setLanguage] in the app so the preference is persisted.
  static set currentLanguage(String language) {
    languageNotifier.value = language;
  }

  /// Loads the persisted language preference. Call once during app startup,
  /// before the first screen is built.
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved != null && supportedLanguages.contains(saved)) {
      languageNotifier.value = saved;
    }
  }

  /// Updates the current language and persists it locally.
  /// Does not call the backend — callers that need the preference synced
  /// server-side (e.g. the Settings screen) should do that separately.
  static Future<void> setLanguage(String language) async {
    if (!supportedLanguages.contains(language)) return;
    languageNotifier.value = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, language);
  }

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

      AppStrings.pleaseAnswerAllQuestions: "Responda todas as perguntas",
      AppStrings.onboardingFailed: "Falha ao enviar respostas",
      AppStrings.noQuestionsAvailable: "Nenhuma pergunta disponível.",
      AppStrings.failedToLoadQuestions: "Falha ao carregar perguntas",

      AppStrings.petProfileTitle: "Perfil do PET",
      AppStrings.failedToSavePet: "Falha ao salvar o pet",

      AppStrings.settingsTitle: "Configurações",
      AppStrings.settingsSubtitle: "Personalize sua experiência, Comandante.",
      AppStrings.languageSectionTitle: "Idioma",
      AppStrings.languagePt: "Português (Brasil)",
      AppStrings.languageEn: "English",
      AppStrings.languageEs: "Español",
      AppStrings.languageUpdated: "Idioma atualizado",
      AppStrings.notificationsSectionTitle: "Notificações",
      AppStrings.dailyMissionReminders: "Lembretes de missões diárias",
      AppStrings.achievementAlerts: "Alertas de conquistas",
      AppStrings.privacySectionTitle: "Privacidade",
      AppStrings.showOnRankings: "Aparecer nos rankings",
      AppStrings.accountSectionTitle: "Conta",
      AppStrings.logoutButton: "Sair",
      AppStrings.logoutConfirmTitle: "Sair do Invest Game?",
      AppStrings.logoutConfirmMessage: "Tem certeza que deseja encerrar sua sessão?",
      AppStrings.cancelButton: "Cancelar",
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

      AppStrings.pleaseAnswerAllQuestions: "Please answer all questions",
      AppStrings.onboardingFailed: "Failed to submit answers",
      AppStrings.noQuestionsAvailable: "No questions available.",
      AppStrings.failedToLoadQuestions: "Failed to load questions",

      AppStrings.petProfileTitle: "Pet Profile",
      AppStrings.failedToSavePet: "Failed to save pet",

      AppStrings.settingsTitle: "Settings",
      AppStrings.settingsSubtitle: "Personalize your experience, Commander.",
      AppStrings.languageSectionTitle: "Language",
      AppStrings.languagePt: "Português (Brasil)",
      AppStrings.languageEn: "English",
      AppStrings.languageEs: "Español",
      AppStrings.languageUpdated: "Language updated",
      AppStrings.notificationsSectionTitle: "Notifications",
      AppStrings.dailyMissionReminders: "Daily mission reminders",
      AppStrings.achievementAlerts: "Achievement alerts",
      AppStrings.privacySectionTitle: "Privacy",
      AppStrings.showOnRankings: "Show up on rankings",
      AppStrings.accountSectionTitle: "Account",
      AppStrings.logoutButton: "Logout",
      AppStrings.logoutConfirmTitle: "Leave Invest Game?",
      AppStrings.logoutConfirmMessage: "Are you sure you want to end your session?",
      AppStrings.cancelButton: "Cancel",
    },
    'es': {
      AppStrings.welcomeBack: "Bienvenido de nuevo",
      AppStrings.loginToContinue: "Inicia sesión para continuar",
      AppStrings.emailOrUserHint: "Correo o Usuario",
      AppStrings.passwordHint: "Contraseña",
      AppStrings.forgotPassword: "¿Olvidaste tu contraseña?",
      AppStrings.noAccountSignUp: "¿No tienes cuenta? Regístrate",
      AppStrings.loginButton: "Entrar",
      AppStrings.createAccount: "Crear Cuenta",
      AppStrings.fillDetails: "Completa tus datos",
      AppStrings.nameHint: "Nombre Completo",
      AppStrings.confirmPasswordHint: "Confirmar Contraseña",
      AppStrings.signupButton: "Registrarse",
      AppStrings.alreadyHaveAccount: "¿Ya tienes cuenta? Entrar",

      AppStrings.pleaseAnswerAllQuestions: "Responde todas las preguntas",
      AppStrings.onboardingFailed: "Error al enviar las respuestas",
      AppStrings.noQuestionsAvailable: "No hay preguntas disponibles.",
      AppStrings.failedToLoadQuestions: "Error al cargar las preguntas",

      AppStrings.petProfileTitle: "Perfil de la Mascota",
      AppStrings.failedToSavePet: "Error al guardar la mascota",

      AppStrings.settingsTitle: "Configuración",
      AppStrings.settingsSubtitle: "Personaliza tu experiencia, Comandante.",
      AppStrings.languageSectionTitle: "Idioma",
      AppStrings.languagePt: "Português (Brasil)",
      AppStrings.languageEn: "English",
      AppStrings.languageEs: "Español",
      AppStrings.languageUpdated: "Idioma actualizado",
      AppStrings.notificationsSectionTitle: "Notificaciones",
      AppStrings.dailyMissionReminders: "Recordatorios de misiones diarias",
      AppStrings.achievementAlerts: "Alertas de logros",
      AppStrings.privacySectionTitle: "Privacidad",
      AppStrings.showOnRankings: "Aparecer en los rankings",
      AppStrings.accountSectionTitle: "Cuenta",
      AppStrings.logoutButton: "Salir",
      AppStrings.logoutConfirmTitle: "¿Salir de Invest Game?",
      AppStrings.logoutConfirmMessage: "¿Seguro que deseas cerrar tu sesión?",
      AppStrings.cancelButton: "Cancelar",
    },
  };

  static String translate(String key) {
    return _localizedValues[currentLanguage]?[key] ?? _localizedValues[defaultLanguage]?[key] ?? key;
  }
}
