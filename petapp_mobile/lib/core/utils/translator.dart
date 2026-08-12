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

      AppStrings.meetPetTitle: "Conheça seu Companheiro",
      AppStrings.meetPetGreeting: "Olá!",
      AppStrings.meetPetIntro: "Sou o seu companheiro financeiro. Vou te ajudar a aprender sobre investimentos, manter a disciplina e comemorar cada conquista da sua jornada.",
      AppStrings.meetPetNeedName: "Mas antes... eu preciso de um nome!",
      AppStrings.meetPetSpeciesPrompt: "Escolha a espécie do seu companheiro",
      AppStrings.meetPetContinue: "Vamos começar!",
      AppStrings.meetPetPreviewTitle: "O que vamos fazer juntos",
      AppStrings.meetPetPreviewCelebrate: "Comemorar cada conquista da sua jornada",
      AppStrings.meetPetPreviewLearn: "Aprender sobre investimentos no seu ritmo",
      AppStrings.meetPetPreviewRemember: "Lembrar dos momentos importantes da nossa jornada",

      AppStrings.namePetTitle: "Escolha o Nome do seu Pet",
      AppStrings.namePetPrompt: "Como você gostaria de chamar seu companheiro?",
      AppStrings.namePetHint: "Nome do companheiro",
      AppStrings.namePetContinue: "Continuar",
      AppStrings.namePetReaction: "Adorei meu novo nome! Vamos começar sua jornada!",
      AppStrings.namePetRequiredError: "Escolha um nome para continuar",

      AppStrings.financialGoalTitle: "Qual é o seu objetivo?",
      AppStrings.financialGoalSubtitle: "Não se preocupe, você pode mudar isso depois. Isso só nos ajuda a personalizar sua jornada.",
      AppStrings.financialGoalContinue: "Continuar",

      AppStrings.tutorialSkip: "Pular",
      AppStrings.tutorialNext: "Próximo",
      AppStrings.tutorialEnterHome: "Entrar no App",
      AppStrings.tutorialStep1Title: "Sua Jornada, Gamificada",
      AppStrings.tutorialStep1Body: "Complete missões, ganhe XP e evolua seu pet conforme você aprende e investe.",
      AppStrings.tutorialStep2Title: "Aprenda no seu Ritmo",
      AppStrings.tutorialStep2Body: "Lições curtas e quizzes te ensinam o essencial sobre investir, sem pressa.",
      AppStrings.tutorialStep3Title: "Seu Portfólio, Quando Quiser",
      AppStrings.tutorialStep3Body: "Conectar seus investimentos é opcional — você pode explorar o app à vontade primeiro.",

      AppStrings.portfolioChoiceTitle: "Quer conectar seus investimentos agora?",
      AppStrings.portfolioChoiceBody: "Você pode importar seu portfólio automaticamente, adicionar manualmente, ou pular por enquanto. Você sempre pode fazer isso depois.",
      AppStrings.portfolioChoiceFootnote: "Não há pressa — {petName} vai estar aqui quando você estiver pronto.",
      AppStrings.importPortfolioButton: "Importar Portfólio",
      AppStrings.addManuallyButton: "Adicionar Manualmente",
      AppStrings.skipForNowButton: "Pular por Enquanto",
      AppStrings.importComingSoonTitle: "Em breve",
      AppStrings.importComingSoonBody: "A importação automática (B3, corretoras, CSV) ainda está sendo construída. Por enquanto, você pode adicionar seus ativos manualmente ou pular esta etapa.",
      AppStrings.okButton: "Entendi",

      AppStrings.portfolioNotConnectedTitle: "Portfólio ainda não conectado",
      AppStrings.portfolioNotConnectedBody: "Conecte seus investimentos quando estiver pronto — sem pressa.",
      AppStrings.connectInvestmentsButton: "Conectar Investimentos",
      AppStrings.suggestedActionsTitle: "O que fazer agora",
      AppStrings.suggestedActionCompleteLesson: "Concluir sua primeira lição",
      AppStrings.suggestedActionTodayMission: "Concluir a missão de hoje",
      AppStrings.suggestedActionLearnDividends: "Aprender sobre dividendos",
      AppStrings.suggestedActionFirstQuiz: "Fazer seu primeiro quiz",
      AppStrings.suggestedActionInvestorProfile: "Completar seu perfil de investidor",
      AppStrings.comingSoonSnack: "Em construção — em breve!",

      AppStrings.portfolioReminderMessage: "Percebi que ainda não conectamos seus investimentos. Quando você quiser, posso analisar seu portfólio e criar missões personalizadas. Não há pressa.",
      AppStrings.portfolioReminderCta: "Conectar agora",
      AppStrings.portfolioReminderDismiss: "Agora não",

      AppStrings.companionSectionTitle: "Companheiro",
      AppStrings.renamePetLabel: "Nome do companheiro",
      AppStrings.renamePetButton: "Renomear",
      AppStrings.renamePetDialogTitle: "Renomear companheiro",
      AppStrings.renamePetSuccess: "Nome atualizado!",

      AppStrings.settingsTitle: "Configurações",
      AppStrings.settingsSubtitle: "Personalize sua experiência, Comandante.",
      AppStrings.languageSectionTitle: "Idioma",
      AppStrings.languagePt: "Português (Brasil)",
      AppStrings.languageEn: "English",
      AppStrings.languageEs: "Español",
      AppStrings.languageUpdated: "Idioma atualizado",
      AppStrings.appearanceSectionTitle: "Aparência",
      AppStrings.appearanceLightLabel: "Claro",
      AppStrings.appearanceLightDescription: "Brilhante, limpo e acolhedor",
      AppStrings.appearanceDarkLabel: "Escuro",
      AppStrings.appearanceDarkDescription: "Premium, imersivo e futurista",
      AppStrings.appearanceSystemLabel: "Sistema",
      AppStrings.appearanceSystemDescription: "Segue as configurações do aparelho",
      AppStrings.appearanceUpdated: "Aparência atualizada",
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

      AppStrings.levelUpAchieved: "Nível {level} alcançado!",

      AppStrings.academyLevelLabel: "Investidor Nível {level}",
      AppStrings.academyXpEarnedLabel: "{xp} XP conquistados na Academia",
      AppStrings.academyContinueSectionLabel: "CONTINUAR",
      AppStrings.academyXpToCompleteLabel: "+{xp} XP ao concluir",
      AppStrings.academyStartLessonButton: "Começar Lição",
      AppStrings.academyModulesSectionLabel: "MÓDULOS",
      AppStrings.academyLessonsSectionLabel: "LIÇÕES",
      AppStrings.academyLessonsProgressLabel: "{completed} / {total} lições",
      AppStrings.academyLessonCompleteTitle: "Lição Concluída!",
      AppStrings.academyXpPill: "+{xp} XP",
      AppStrings.academyContinueButton: "Continuar",
      AppStrings.academyConcludeButton: "Concluir",
      AppStrings.academyBackToAcademyButton: "Voltar à Academia",
      AppStrings.academyModuleStatusCompleted: "MÓDULO CONCLUÍDO",
      AppStrings.academyModuleStatusInProgress: "EM ANDAMENTO",
      AppStrings.academyModuleStatusAvailable: "DISPONÍVEL",
      AppStrings.academyModuleStatusComingSoon: "EM BREVE",
      AppStrings.academyMicroExerciseLabel: "EXERCÍCIO RÁPIDO",
      AppStrings.academyApplyLabel: "APLIQUE O QUE APRENDEU",
      AppStrings.academyCorrectFeedbackTitle: "Isso mesmo!",
      AppStrings.academyIncorrectFeedbackTitle: "Quase! Vamos entender:",

      AppStrings.appBarPlayerNamedGreeting: "{petName} · Nível {level}",
      AppStrings.appBarPlayerGenericGreeting: "Nível {level} · Explorador",
      AppStrings.profileTooltip: "Perfil",
      AppStrings.notificationsTooltip: "Notificações",
      AppStrings.logoutTooltip: "Sair",
      AppStrings.navHome: "Início",
      AppStrings.navWallet: "Carteira",
      AppStrings.navPassiveIncome: "Proventos",
      AppStrings.navAcademy: "Academia",
      AppStrings.navMentor: "Mentor",
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

      AppStrings.meetPetTitle: "Meet Your Companion",
      AppStrings.meetPetGreeting: "Hello!",
      AppStrings.meetPetIntro: "I'm your financial companion. I'll help you learn about investing, stay disciplined and celebrate every achievement along your journey.",
      AppStrings.meetPetNeedName: "But first... I need a name!",
      AppStrings.meetPetSpeciesPrompt: "Choose your companion's species",
      AppStrings.meetPetContinue: "Let's get started!",
      AppStrings.meetPetPreviewTitle: "What we'll do together",
      AppStrings.meetPetPreviewCelebrate: "Celebrate every milestone of your journey",
      AppStrings.meetPetPreviewLearn: "Learn about investing at your own pace",
      AppStrings.meetPetPreviewRemember: "Remember the important moments of our journey",

      AppStrings.namePetTitle: "Name Your Pet",
      AppStrings.namePetPrompt: "What would you like to call your companion?",
      AppStrings.namePetHint: "Companion's name",
      AppStrings.namePetContinue: "Continue",
      AppStrings.namePetReaction: "I love my new name! Let's start your journey!",
      AppStrings.namePetRequiredError: "Choose a name to continue",

      AppStrings.financialGoalTitle: "What's your goal?",
      AppStrings.financialGoalSubtitle: "Don't worry, you can change this later. It just helps us personalize your journey.",
      AppStrings.financialGoalContinue: "Continue",

      AppStrings.tutorialSkip: "Skip",
      AppStrings.tutorialNext: "Next",
      AppStrings.tutorialEnterHome: "Enter the App",
      AppStrings.tutorialStep1Title: "Your Journey, Gamified",
      AppStrings.tutorialStep1Body: "Complete missions, earn XP and evolve your pet as you learn and invest.",
      AppStrings.tutorialStep2Title: "Learn at Your Own Pace",
      AppStrings.tutorialStep2Body: "Short lessons and quizzes teach you the essentials of investing, no rush.",
      AppStrings.tutorialStep3Title: "Your Portfolio, Whenever You're Ready",
      AppStrings.tutorialStep3Body: "Connecting your investments is optional — feel free to explore the app first.",

      AppStrings.portfolioChoiceTitle: "Would you like to connect your investments now?",
      AppStrings.portfolioChoiceBody: "You can import your portfolio automatically, add investments manually, or skip for now. You can always do this later.",
      AppStrings.portfolioChoiceFootnote: "There's no rush — {petName} will be here when you're ready.",
      AppStrings.importPortfolioButton: "Import Portfolio",
      AppStrings.addManuallyButton: "Add Manually",
      AppStrings.skipForNowButton: "Skip For Now",
      AppStrings.importComingSoonTitle: "Coming soon",
      AppStrings.importComingSoonBody: "Automatic import (B3, brokers, CSV) is still being built. For now, you can add your assets manually or skip this step.",
      AppStrings.okButton: "Got it",

      AppStrings.portfolioNotConnectedTitle: "Portfolio not connected yet",
      AppStrings.portfolioNotConnectedBody: "Connect your investments whenever you're ready — no rush.",
      AppStrings.connectInvestmentsButton: "Connect Investments",
      AppStrings.suggestedActionsTitle: "What to do now",
      AppStrings.suggestedActionCompleteLesson: "Complete your first lesson",
      AppStrings.suggestedActionTodayMission: "Complete today's mission",
      AppStrings.suggestedActionLearnDividends: "Learn about dividends",
      AppStrings.suggestedActionFirstQuiz: "Start your first quiz",
      AppStrings.suggestedActionInvestorProfile: "Complete your investor profile",
      AppStrings.comingSoonSnack: "Coming soon!",

      AppStrings.portfolioReminderMessage: "I noticed we still haven't connected your investments. When you're ready, I can analyze your portfolio and create personalized missions. There is no rush.",
      AppStrings.portfolioReminderCta: "Connect now",
      AppStrings.portfolioReminderDismiss: "Not now",

      AppStrings.companionSectionTitle: "Companion",
      AppStrings.renamePetLabel: "Companion's name",
      AppStrings.renamePetButton: "Rename",
      AppStrings.renamePetDialogTitle: "Rename companion",
      AppStrings.renamePetSuccess: "Name updated!",

      AppStrings.settingsTitle: "Settings",
      AppStrings.settingsSubtitle: "Personalize your experience, Commander.",
      AppStrings.languageSectionTitle: "Language",
      AppStrings.languagePt: "Português (Brasil)",
      AppStrings.languageEn: "English",
      AppStrings.languageEs: "Español",
      AppStrings.languageUpdated: "Language updated",
      AppStrings.appearanceSectionTitle: "Appearance",
      AppStrings.appearanceLightLabel: "Light",
      AppStrings.appearanceLightDescription: "Bright, clean and friendly",
      AppStrings.appearanceDarkLabel: "Dark",
      AppStrings.appearanceDarkDescription: "Premium, immersive and futuristic",
      AppStrings.appearanceSystemLabel: "System",
      AppStrings.appearanceSystemDescription: "Follows your device settings",
      AppStrings.appearanceUpdated: "Appearance updated",
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

      AppStrings.levelUpAchieved: "Level {level} reached!",

      AppStrings.academyLevelLabel: "Investor Level {level}",
      AppStrings.academyXpEarnedLabel: "{xp} XP earned in the Academy",
      AppStrings.academyContinueSectionLabel: "CONTINUE",
      AppStrings.academyXpToCompleteLabel: "+{xp} XP on completion",
      AppStrings.academyStartLessonButton: "Start Lesson",
      AppStrings.academyModulesSectionLabel: "MODULES",
      AppStrings.academyLessonsSectionLabel: "LESSONS",
      AppStrings.academyLessonsProgressLabel: "{completed} / {total} lessons",
      AppStrings.academyLessonCompleteTitle: "Lesson Complete!",
      AppStrings.academyXpPill: "+{xp} XP",
      AppStrings.academyContinueButton: "Continue",
      AppStrings.academyConcludeButton: "Finish",
      AppStrings.academyBackToAcademyButton: "Back to Academy",
      AppStrings.academyModuleStatusCompleted: "MODULE COMPLETED",
      AppStrings.academyModuleStatusInProgress: "IN PROGRESS",
      AppStrings.academyModuleStatusAvailable: "AVAILABLE",
      AppStrings.academyModuleStatusComingSoon: "COMING SOON",
      AppStrings.academyMicroExerciseLabel: "QUICK EXERCISE",
      AppStrings.academyApplyLabel: "APPLY WHAT YOU LEARNED",
      AppStrings.academyCorrectFeedbackTitle: "That's right!",
      AppStrings.academyIncorrectFeedbackTitle: "Almost! Let's understand:",

      AppStrings.appBarPlayerNamedGreeting: "{petName} · Level {level}",
      AppStrings.appBarPlayerGenericGreeting: "Level {level} · Explorer",
      AppStrings.profileTooltip: "Profile",
      AppStrings.notificationsTooltip: "Notifications",
      AppStrings.logoutTooltip: "Logout",
      AppStrings.navHome: "Home",
      AppStrings.navWallet: "Wallet",
      AppStrings.navPassiveIncome: "Income",
      AppStrings.navAcademy: "Academy",
      AppStrings.navMentor: "Mentor",
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

      AppStrings.meetPetTitle: "Conoce a tu Compañero",
      AppStrings.meetPetGreeting: "¡Hola!",
      AppStrings.meetPetIntro: "Soy tu compañero financiero. Te ayudaré a aprender sobre inversiones, mantener la disciplina y celebrar cada logro en tu camino.",
      AppStrings.meetPetNeedName: "Pero antes... ¡necesito un nombre!",
      AppStrings.meetPetSpeciesPrompt: "Elige la especie de tu compañero",
      AppStrings.meetPetContinue: "¡Vamos a empezar!",
      AppStrings.meetPetPreviewTitle: "Lo que haremos juntos",
      AppStrings.meetPetPreviewCelebrate: "Celebrar cada logro de tu viaje",
      AppStrings.meetPetPreviewLearn: "Aprender sobre inversiones a tu ritmo",
      AppStrings.meetPetPreviewRemember: "Recordar los momentos importantes de nuestro viaje",

      AppStrings.namePetTitle: "Nombra a tu Mascota",
      AppStrings.namePetPrompt: "¿Cómo te gustaría llamar a tu compañero?",
      AppStrings.namePetHint: "Nombre del compañero",
      AppStrings.namePetContinue: "Continuar",
      AppStrings.namePetReaction: "¡Me encanta mi nuevo nombre! ¡Comencemos tu viaje!",
      AppStrings.namePetRequiredError: "Elige un nombre para continuar",

      AppStrings.financialGoalTitle: "¿Cuál es tu objetivo?",
      AppStrings.financialGoalSubtitle: "No te preocupes, puedes cambiar esto después. Solo nos ayuda a personalizar tu experiencia.",
      AppStrings.financialGoalContinue: "Continuar",

      AppStrings.tutorialSkip: "Omitir",
      AppStrings.tutorialNext: "Siguiente",
      AppStrings.tutorialEnterHome: "Entrar a la App",
      AppStrings.tutorialStep1Title: "Tu Viaje, Gamificado",
      AppStrings.tutorialStep1Body: "Completa misiones, gana XP y evoluciona a tu mascota mientras aprendes e inviertes.",
      AppStrings.tutorialStep2Title: "Aprende a tu Ritmo",
      AppStrings.tutorialStep2Body: "Lecciones cortas y quizzes te enseñan lo esencial sobre invertir, sin prisa.",
      AppStrings.tutorialStep3Title: "Tu Portafolio, Cuando Quieras",
      AppStrings.tutorialStep3Body: "Conectar tus inversiones es opcional — puedes explorar la app primero.",

      AppStrings.portfolioChoiceTitle: "¿Quieres conectar tus inversiones ahora?",
      AppStrings.portfolioChoiceBody: "Puedes importar tu portafolio automáticamente, agregar inversiones manualmente, o omitir por ahora. Siempre puedes hacerlo después.",
      AppStrings.portfolioChoiceFootnote: "No hay prisa — {petName} estará aquí cuando estés listo.",
      AppStrings.importPortfolioButton: "Importar Portafolio",
      AppStrings.addManuallyButton: "Agregar Manualmente",
      AppStrings.skipForNowButton: "Omitir por Ahora",
      AppStrings.importComingSoonTitle: "Próximamente",
      AppStrings.importComingSoonBody: "La importación automática (B3, corredoras, CSV) todavía se está construyendo. Por ahora, puedes agregar tus activos manualmente u omitir este paso.",
      AppStrings.okButton: "Entendido",

      AppStrings.portfolioNotConnectedTitle: "Portafolio aún no conectado",
      AppStrings.portfolioNotConnectedBody: "Conecta tus inversiones cuando estés listo — no hay prisa.",
      AppStrings.connectInvestmentsButton: "Conectar Inversiones",
      AppStrings.suggestedActionsTitle: "Qué hacer ahora",
      AppStrings.suggestedActionCompleteLesson: "Completar tu primera lección",
      AppStrings.suggestedActionTodayMission: "Completar la misión de hoy",
      AppStrings.suggestedActionLearnDividends: "Aprender sobre dividendos",
      AppStrings.suggestedActionFirstQuiz: "Hacer tu primer quiz",
      AppStrings.suggestedActionInvestorProfile: "Completar tu perfil de inversionista",
      AppStrings.comingSoonSnack: "¡Próximamente!",

      AppStrings.portfolioReminderMessage: "Noté que todavía no hemos conectado tus inversiones. Cuando estés listo, puedo analizar tu portafolio y crear misiones personalizadas. No hay prisa.",
      AppStrings.portfolioReminderCta: "Conectar ahora",
      AppStrings.portfolioReminderDismiss: "Ahora no",

      AppStrings.companionSectionTitle: "Compañero",
      AppStrings.renamePetLabel: "Nombre del compañero",
      AppStrings.renamePetButton: "Renombrar",
      AppStrings.renamePetDialogTitle: "Renombrar compañero",
      AppStrings.renamePetSuccess: "¡Nombre actualizado!",

      AppStrings.settingsTitle: "Configuración",
      AppStrings.settingsSubtitle: "Personaliza tu experiencia, Comandante.",
      AppStrings.languageSectionTitle: "Idioma",
      AppStrings.languagePt: "Português (Brasil)",
      AppStrings.languageEn: "English",
      AppStrings.languageEs: "Español",
      AppStrings.languageUpdated: "Idioma actualizado",
      AppStrings.appearanceSectionTitle: "Apariencia",
      AppStrings.appearanceLightLabel: "Claro",
      AppStrings.appearanceLightDescription: "Brillante, limpio y acogedor",
      AppStrings.appearanceDarkLabel: "Oscuro",
      AppStrings.appearanceDarkDescription: "Premium, inmersivo y futurista",
      AppStrings.appearanceSystemLabel: "Sistema",
      AppStrings.appearanceSystemDescription: "Sigue la configuración de tu dispositivo",
      AppStrings.appearanceUpdated: "Apariencia actualizada",
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

      AppStrings.levelUpAchieved: "¡Nivel {level} alcanzado!",

      AppStrings.academyLevelLabel: "Inversor Nivel {level}",
      AppStrings.academyXpEarnedLabel: "{xp} XP conseguidos en la Academia",
      AppStrings.academyContinueSectionLabel: "CONTINUAR",
      AppStrings.academyXpToCompleteLabel: "+{xp} XP al completar",
      AppStrings.academyStartLessonButton: "Comenzar Lección",
      AppStrings.academyModulesSectionLabel: "MÓDULOS",
      AppStrings.academyLessonsSectionLabel: "LECCIONES",
      AppStrings.academyLessonsProgressLabel: "{completed} / {total} lecciones",
      AppStrings.academyLessonCompleteTitle: "¡Lección Completada!",
      AppStrings.academyXpPill: "+{xp} XP",
      AppStrings.academyContinueButton: "Continuar",
      AppStrings.academyConcludeButton: "Concluir",
      AppStrings.academyBackToAcademyButton: "Volver a la Academia",
      AppStrings.academyModuleStatusCompleted: "MÓDULO COMPLETADO",
      AppStrings.academyModuleStatusInProgress: "EN CURSO",
      AppStrings.academyModuleStatusAvailable: "DISPONIBLE",
      AppStrings.academyModuleStatusComingSoon: "PRÓXIMAMENTE",
      AppStrings.academyMicroExerciseLabel: "EJERCICIO RÁPIDO",
      AppStrings.academyApplyLabel: "APLICA LO QUE APRENDISTE",
      AppStrings.academyCorrectFeedbackTitle: "¡Exacto!",
      AppStrings.academyIncorrectFeedbackTitle: "¡Casi! Vamos a entender:",

      AppStrings.appBarPlayerNamedGreeting: "{petName} · Nivel {level}",
      AppStrings.appBarPlayerGenericGreeting: "Nivel {level} · Explorador",
      AppStrings.profileTooltip: "Perfil",
      AppStrings.notificationsTooltip: "Notificaciones",
      AppStrings.logoutTooltip: "Salir",
      AppStrings.navHome: "Inicio",
      AppStrings.navWallet: "Cartera",
      AppStrings.navPassiveIncome: "Ingresos",
      AppStrings.navAcademy: "Academia",
      AppStrings.navMentor: "Mentor",
    },
  };

  /// [params] fills `{token}` placeholders in the translated string (e.g.
  /// `{petName}`) — used for copy that embeds the user's chosen pet name,
  /// which can't be baked into the static translation map.
  static String translate(String key, {Map<String, String>? params}) {
    var value = _localizedValues[currentLanguage]?[key] ?? _localizedValues[defaultLanguage]?[key] ?? key;
    if (params != null) {
      for (final entry in params.entries) {
        value = value.replaceAll('{${entry.key}}', entry.value);
      }
    }
    return value;
  }
}
