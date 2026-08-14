import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/constants/app_strings.dart';
import 'package:petrimonium/core/di/dependency_injection.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/utils/game_snack.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/core/theme/background_presets.dart';
import 'package:petrimonium/core/widgets/cosmic_background.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/core/widgets/app_loading_indicator.dart';
import 'package:petrimonium/core/widgets/confirm_logout_dialog.dart';
import 'package:petrimonium/features/auth/presentation/screens/login_screen.dart';
import 'package:petrimonium/features/settings/presentation/widgets/appearance_section.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _dailyMissionRemindersKey = 'settings_daily_mission_reminders';
  static const _achievementAlertsKey = 'settings_achievement_alerts';
  static const _showOnRankingsKey = 'settings_show_on_rankings';

  String? _email;
  String? _petName;
  bool _dailyMissionReminders = true;
  bool _achievementAlerts = true;
  bool _showOnRankings = true;
  bool _loadingPrefs = true;

  @override
  void initState() {
    super.initState();
    _loadLocalPreferences();
  }

  Future<void> _loadLocalPreferences() async {
    final email = await DI.authRepository.getSavedEmail();
    final profile = await DI.mascotRepository.loadProfile();
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _email = email;
      _petName = profile.name;
      _dailyMissionReminders = prefs.getBool(_dailyMissionRemindersKey) ?? true;
      _achievementAlerts = prefs.getBool(_achievementAlertsKey) ?? true;
      _showOnRankings = prefs.getBool(_showOnRankingsKey) ?? true;
      _loadingPrefs = false;
    });
  }

  Future<void> _handleRenamePet() async {
    final tokens = context.colors;
    final controller = TextEditingController(text: _petName);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: tokens.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          Translator.translate(AppStrings.renamePetDialogTitle),
          style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          style: TextStyle(color: tokens.textPrimary),
          decoration: InputDecoration(
            hintText: Translator.translate(AppStrings.namePetHint),
            hintStyle: TextStyle(color: tokens.textTertiary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(Translator.translate(AppStrings.cancelButton), style: TextStyle(color: tokens.primary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(Translator.translate(AppStrings.renamePetButton), style: TextStyle(color: tokens.primary)),
          ),
        ],
      ),
    );

    if (newName == null || newName.isEmpty || !mounted) return;
    await DI.mascotRepository.saveName(newName);
    if (!mounted) return;
    setState(() => _petName = newName);
    GameSnack.show(context, Translator.translate(AppStrings.renamePetSuccess), isSuccess: true);
  }

  Future<void> _setBoolPref(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _handleLanguageSelected(String language) async {
    if (language == Translator.currentLanguage) return;
    HapticFeedback.selectionClick();
    await Translator.setLanguage(language);
    await DI.settingsRepository.syncLanguage(language);
    if (!mounted) return;
    setState(() {});
    GameSnack.show(context, Translator.translate(AppStrings.languageUpdated), isSuccess: true);
  }

  Future<void> _confirmLogout() async {
    final confirmed = await ConfirmLogoutDialog.show(context);

    if (confirmed && mounted) {
      HapticFeedback.mediumImpact();
      await DI.authRepository.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: Translator.languageNotifier,
      builder: (context, _, __) => _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final tokens = context.colors;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(Translator.translate(AppStrings.settingsTitle), style: TextStyle(color: tokens.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: tokens.textPrimary),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
      ),
      body: CosmicBackground(
        intensity: BackgroundIntensity.balanced,
        child: SafeArea(
          child: _loadingPrefs
              ? const AppLoadingIndicator()
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        Translator.translate(AppStrings.settingsSubtitle),
                        style: TextStyle(color: tokens.textSecondary, fontSize: 14),
                      ),
                      const SizedBox(height: 20),
                      _buildCompanionSection(),
                      const SizedBox(height: 20),
                      _buildLanguageSection(),
                      const SizedBox(height: 20),
                      AppearanceSection(sectionLabel: _sectionLabel),
                      const SizedBox(height: 20),
                      _buildNotificationsSection(),
                      const SizedBox(height: 20),
                      _buildPrivacySection(),
                      const SizedBox(height: 20),
                      _buildAccountSection(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: TextStyle(
          color: context.colors.primary.withValues(alpha: 0.8),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildCompanionSection() {
    final tokens = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(Translator.translate(AppStrings.companionSectionTitle).toUpperCase()),
        GlassCard(
          backgroundColor: tokens.surface.withValues(alpha: context.isDarkMode ? 0.6 : 0.94),
          borderColor: AppColors.neonPink.withValues(alpha: 0.3),
          borderRadius: 20,
          borderWidth: 1,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.pets, color: AppColors.neonPink, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Translator.translate(AppStrings.renamePetLabel),
                      style: TextStyle(color: tokens.textSecondary, fontSize: 12),
                    ),
                    Text(
                      (_petName?.isNotEmpty ?? false) ? _petName! : '—',
                      style: TextStyle(color: tokens.textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: _handleRenamePet,
                child: Text(
                  Translator.translate(AppStrings.renamePetButton),
                  style: const TextStyle(color: AppColors.neonPink, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSection() {
    final tokens = context.colors;
    final languages = [
      (code: 'pt', label: Translator.translate(AppStrings.languagePt), flag: '🇧🇷'),
      (code: 'en', label: Translator.translate(AppStrings.languageEn), flag: '🇺🇸'),
      (code: 'es', label: Translator.translate(AppStrings.languageEs), flag: '🇪🇸'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(Translator.translate(AppStrings.languageSectionTitle).toUpperCase()),
        GlassCard(
          backgroundColor: tokens.surface.withValues(alpha: context.isDarkMode ? 0.6 : 0.94),
          borderColor: AppColors.neonCyan.withValues(alpha: 0.3),
          borderRadius: 20,
          borderWidth: 1,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: languages.map((lang) {
              final isSelected = Translator.currentLanguage == lang.code;
              return InkWell(
                onTap: () => _handleLanguageSelected(lang.code),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Text(lang.flag, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          lang.label,
                          style: TextStyle(
                            color: isSelected ? tokens.textPrimary : tokens.textSecondary,
                            fontSize: 15,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (isSelected) Icon(Icons.check_circle, color: tokens.primary, size: 20),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleCard({required List<Widget> children}) {
    final tokens = context.colors;
    return GlassCard(
      backgroundColor: tokens.surface.withValues(alpha: context.isDarkMode ? 0.6 : 0.94),
      borderColor: AppColors.neonCyan.withValues(alpha: 0.3),
      borderRadius: 20,
      borderWidth: 1,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final tokens = context.colors;
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeTrackColor: tokens.primary.withValues(alpha: 0.5),
      activeThumbColor: tokens.primary,
      secondary: Icon(icon, color: tokens.textSecondary),
      title: Text(label, style: TextStyle(color: tokens.textPrimary, fontSize: 14)),
    );
  }

  Widget _buildNotificationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(Translator.translate(AppStrings.notificationsSectionTitle).toUpperCase()),
        _buildToggleCard(children: [
          _buildSwitchTile(
            icon: Icons.notifications_active_outlined,
            label: Translator.translate(AppStrings.dailyMissionReminders),
            value: _dailyMissionReminders,
            onChanged: (v) {
              setState(() => _dailyMissionReminders = v);
              _setBoolPref(_dailyMissionRemindersKey, v);
            },
          ),
          _buildSwitchTile(
            icon: Icons.emoji_events_outlined,
            label: Translator.translate(AppStrings.achievementAlerts),
            value: _achievementAlerts,
            onChanged: (v) {
              setState(() => _achievementAlerts = v);
              _setBoolPref(_achievementAlertsKey, v);
            },
          ),
        ]),
      ],
    );
  }

  Widget _buildPrivacySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(Translator.translate(AppStrings.privacySectionTitle).toUpperCase()),
        _buildToggleCard(children: [
          _buildSwitchTile(
            icon: Icons.leaderboard_outlined,
            label: Translator.translate(AppStrings.showOnRankings),
            value: _showOnRankings,
            onChanged: (v) {
              setState(() => _showOnRankings = v);
              _setBoolPref(_showOnRankingsKey, v);
            },
          ),
        ]),
      ],
    );
  }

  Widget _buildAccountSection() {
    final tokens = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(Translator.translate(AppStrings.accountSectionTitle).toUpperCase()),
        GlassCard(
          backgroundColor: tokens.surface.withValues(alpha: context.isDarkMode ? 0.6 : 0.94),
          borderColor: AppColors.neonPink.withValues(alpha: 0.3),
          borderRadius: 20,
          borderWidth: 1,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_email != null) ...[
                Row(
                  children: [
                    Icon(Icons.person_outline, color: tokens.textSecondary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(_email!, style: TextStyle(color: tokens.textPrimary, fontSize: 14)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: tokens.divider),
                const SizedBox(height: 8),
              ],
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _confirmLogout,
                  icon: Icon(Icons.logout, color: tokens.error),
                  label: Text(
                    Translator.translate(AppStrings.logoutButton),
                    style: TextStyle(color: tokens.error, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: tokens.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
