class AppStrings {
  AppStrings._();

  static const String welcomeBack = "welcomeBack";
  static const String loginToContinue = "loginToContinue";
  static const String emailOrUserHint = "emailOrUserHint";
  static const String passwordHint = "passwordHint";
  static const String forgotPassword = "forgotPassword";
  static const String noAccountSignUp = "noAccountSignUp";
  static const String loginButton = "loginButton";

  // Signup
  static const String createAccount = "createAccount";
  static const String fillDetails = "fillDetails";
  static const String nameHint = "nameHint";
  static const String confirmPasswordHint = "confirmPasswordHint";
  static const String signupButton = "signupButton";
  static const String alreadyHaveAccount = "alreadyHaveAccount";

  // Onboarding
  static const String pleaseAnswerAllQuestions = "pleaseAnswerAllQuestions";
  static const String onboardingFailed = "onboardingFailed";
  static const String noQuestionsAvailable = "noQuestionsAvailable";
  static const String failedToLoadQuestions = "failedToLoadQuestions";

  // Pet configuration
  // Reserved for the future persistent Companion Home screen — the
  // onboarding "meet your pet" step below uses `meetPetTitle` instead so the
  // two screens don't share a title before Companion Home exists.
  static const String petProfileTitle = "petProfileTitle";
  static const String failedToSavePet = "failedToSavePet";

  // Meet Your Pet (onboarding)
  static const String meetPetTitle = "meetPetTitle";
  static const String meetPetGreeting = "meetPetGreeting";
  static const String meetPetIntro = "meetPetIntro";
  static const String meetPetNeedName = "meetPetNeedName";
  static const String meetPetSpeciesPrompt = "meetPetSpeciesPrompt";
  static const String meetPetContinue = "meetPetContinue";
  static const String meetPetPreviewTitle = "meetPetPreviewTitle";
  static const String meetPetPreviewCelebrate = "meetPetPreviewCelebrate";
  static const String meetPetPreviewLearn = "meetPetPreviewLearn";
  static const String meetPetPreviewRemember = "meetPetPreviewRemember";

  // Name Your Pet (onboarding)
  static const String namePetTitle = "namePetTitle";
  static const String namePetPrompt = "namePetPrompt";
  static const String namePetHint = "namePetHint";
  static const String namePetContinue = "namePetContinue";
  static const String namePetReaction = "namePetReaction";
  static const String namePetRequiredError = "namePetRequiredError";

  // Financial Goal (onboarding)
  static const String financialGoalTitle = "financialGoalTitle";
  static const String financialGoalSubtitle = "financialGoalSubtitle";
  static const String financialGoalContinue = "financialGoalContinue";

  // Tutorial (onboarding)
  static const String tutorialSkip = "tutorialSkip";
  static const String tutorialNext = "tutorialNext";
  static const String tutorialEnterHome = "tutorialEnterHome";
  static const String tutorialStep1Title = "tutorialStep1Title";
  static const String tutorialStep1Body = "tutorialStep1Body";
  static const String tutorialStep2Title = "tutorialStep2Title";
  static const String tutorialStep2Body = "tutorialStep2Body";
  static const String tutorialStep3Title = "tutorialStep3Title";
  static const String tutorialStep3Body = "tutorialStep3Body";

  // Portfolio choice (onboarding — optional portfolio connection)
  static const String portfolioChoiceTitle = "portfolioChoiceTitle";
  static const String portfolioChoiceBody = "portfolioChoiceBody";
  static const String portfolioChoiceFootnote = "portfolioChoiceFootnote";
  static const String importPortfolioButton = "importPortfolioButton";
  static const String addManuallyButton = "addManuallyButton";
  static const String skipForNowButton = "skipForNowButton";
  static const String importComingSoonTitle = "importComingSoonTitle";
  static const String importComingSoonBody = "importComingSoonBody";
  static const String okButton = "okButton";

  // Home — portfolio-not-connected placeholder & suggested actions
  static const String portfolioNotConnectedTitle = "portfolioNotConnectedTitle";
  static const String portfolioNotConnectedBody = "portfolioNotConnectedBody";
  static const String connectInvestmentsButton = "connectInvestmentsButton";
  static const String suggestedActionsTitle = "suggestedActionsTitle";
  static const String suggestedActionCompleteLesson = "suggestedActionCompleteLesson";
  static const String suggestedActionTodayMission = "suggestedActionTodayMission";
  static const String suggestedActionLearnDividends = "suggestedActionLearnDividends";
  static const String suggestedActionFirstQuiz = "suggestedActionFirstQuiz";
  static const String suggestedActionInvestorProfile = "suggestedActionInvestorProfile";
  static const String comingSoonSnack = "comingSoonSnack";

  // Portfolio reminder (gentle nudge after skipping)
  static const String portfolioReminderMessage = "portfolioReminderMessage";
  static const String portfolioReminderCta = "portfolioReminderCta";
  static const String portfolioReminderDismiss = "portfolioReminderDismiss";

  // Settings — companion / rename pet
  static const String companionSectionTitle = "companionSectionTitle";
  static const String renamePetLabel = "renamePetLabel";
  static const String renamePetButton = "renamePetButton";
  static const String renamePetDialogTitle = "renamePetDialogTitle";
  static const String renamePetSuccess = "renamePetSuccess";

  // Settings
  static const String settingsTitle = "settingsTitle";
  static const String settingsSubtitle = "settingsSubtitle";
  static const String languageSectionTitle = "languageSectionTitle";
  static const String languagePt = "languagePt";
  static const String languageEn = "languageEn";
  static const String languageEs = "languageEs";
  static const String languageUpdated = "languageUpdated";
  static const String appearanceSectionTitle = "appearanceSectionTitle";
  static const String appearanceLightLabel = "appearanceLightLabel";
  static const String appearanceLightDescription = "appearanceLightDescription";
  static const String appearanceDarkLabel = "appearanceDarkLabel";
  static const String appearanceDarkDescription = "appearanceDarkDescription";
  static const String appearanceSystemLabel = "appearanceSystemLabel";
  static const String appearanceSystemDescription = "appearanceSystemDescription";
  static const String appearanceUpdated = "appearanceUpdated";
  static const String notificationsSectionTitle = "notificationsSectionTitle";
  static const String dailyMissionReminders = "dailyMissionReminders";
  static const String achievementAlerts = "achievementAlerts";
  static const String privacySectionTitle = "privacySectionTitle";
  static const String showOnRankings = "showOnRankings";
  static const String accountSectionTitle = "accountSectionTitle";
  static const String logoutButton = "logoutButton";
  static const String logoutConfirmTitle = "logoutConfirmTitle";
  static const String logoutConfirmMessage = "logoutConfirmMessage";
  static const String cancelButton = "cancelButton";

  // Dashboard
  static const String levelUpAchieved = "levelUpAchieved";

  // Academy — UI chrome only; curriculum content (module/lesson text) lives
  // in AcademyCatalog itself, keyed off Translator.currentLanguage the same
  // way this map is, since it's domain content, not generic UI copy.
  static const String academyLevelLabel = "academyLevelLabel";
  static const String academyXpEarnedLabel = "academyXpEarnedLabel";
  static const String academyContinueSectionLabel = "academyContinueSectionLabel";
  static const String academyXpToCompleteLabel = "academyXpToCompleteLabel";
  static const String academyStartLessonButton = "academyStartLessonButton";
  static const String academyModulesSectionLabel = "academyModulesSectionLabel";
  static const String academyLessonsSectionLabel = "academyLessonsSectionLabel";
  static const String academyLessonsProgressLabel = "academyLessonsProgressLabel";
  static const String academyLessonCompleteTitle = "academyLessonCompleteTitle";
  static const String academyXpPill = "academyXpPill";
  static const String academyContinueButton = "academyContinueButton";
  static const String academyConcludeButton = "academyConcludeButton";
  static const String academyBackToAcademyButton = "academyBackToAcademyButton";
  static const String academyModuleStatusCompleted = "academyModuleStatusCompleted";
  static const String academyModuleStatusInProgress = "academyModuleStatusInProgress";
  static const String academyModuleStatusAvailable = "academyModuleStatusAvailable";
  static const String academyModuleStatusComingSoon = "academyModuleStatusComingSoon";
  static const String academyMicroExerciseLabel = "academyMicroExerciseLabel";
  static const String academyApplyLabel = "academyApplyLabel";
  static const String academyCorrectFeedbackTitle = "academyCorrectFeedbackTitle";
  static const String academyIncorrectFeedbackTitle = "academyIncorrectFeedbackTitle";

  // Dashboard — AppBar / bottom navigation shell
  static const String appBarPlayerNamedGreeting = "appBarPlayerNamedGreeting";
  static const String appBarPlayerGenericGreeting = "appBarPlayerGenericGreeting";
  static const String profileTooltip = "profileTooltip";
  static const String notificationsTooltip = "notificationsTooltip";
  static const String logoutTooltip = "logoutTooltip";
  static const String navHome = "navHome";
  static const String navWallet = "navWallet";
  static const String navPassiveIncome = "navPassiveIncome";
  static const String navAcademy = "navAcademy";
  static const String navMentor = "navMentor";
}
