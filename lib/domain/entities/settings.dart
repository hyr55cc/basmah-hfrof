import 'package:equatable/equatable.dart';

enum AppThemeMode { system, light, dark }

enum AppLanguage { arabic, english, french, spanish }

/// User settings
class AppSettings extends Equatable {
  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.language = AppLanguage.arabic,
    this.musicEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.notificationsEnabled = true,
    this.dailyReminderEnabled = true,
    this.eventReminderEnabled = true,
    this.showAnimations = true,
    this.hapticOnWordFound = true,
    this.hapticOnLevelComplete = true,
    this.adsRemoved = false,
    this.premiumMember = false,
    this.dataSaverMode = false,
    this.autoSync = true,
    this.analyticsEnabled = true,
  });

  final AppThemeMode themeMode;
  final AppLanguage language;
  final bool musicEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool notificationsEnabled;
  final bool dailyReminderEnabled;
  final bool eventReminderEnabled;
  final bool showAnimations;
  final bool hapticOnWordFound;
  final bool hapticOnLevelComplete;
  final bool adsRemoved;
  final bool premiumMember;
  final bool dataSaverMode;
  final bool autoSync;
  final bool analyticsEnabled;

  AppSettings copyWith({
    AppThemeMode? themeMode,
    AppLanguage? language,
    bool? musicEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? notificationsEnabled,
    bool? dailyReminderEnabled,
    bool? eventReminderEnabled,
    bool? showAnimations,
    bool? hapticOnWordFound,
    bool? hapticOnLevelComplete,
    bool? adsRemoved,
    bool? premiumMember,
    bool? dataSaverMode,
    bool? autoSync,
    bool? analyticsEnabled,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyReminderEnabled:
          dailyReminderEnabled ?? this.dailyReminderEnabled,
      eventReminderEnabled:
          eventReminderEnabled ?? this.eventReminderEnabled,
      showAnimations: showAnimations ?? this.showAnimations,
      hapticOnWordFound: hapticOnWordFound ?? this.hapticOnWordFound,
      hapticOnLevelComplete:
          hapticOnLevelComplete ?? this.hapticOnLevelComplete,
      adsRemoved: adsRemoved ?? this.adsRemoved,
      premiumMember: premiumMember ?? this.premiumMember,
      dataSaverMode: dataSaverMode ?? this.dataSaverMode,
      autoSync: autoSync ?? this.autoSync,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
    );
  }

  @override
  List<Object?> get props => [
        themeMode,
        language,
        musicEnabled,
        soundEnabled,
        vibrationEnabled,
        notificationsEnabled,
        dailyReminderEnabled,
        eventReminderEnabled,
        showAnimations,
        hapticOnWordFound,
        hapticOnLevelComplete,
        adsRemoved,
        premiumMember,
        dataSaverMode,
        autoSync,
        analyticsEnabled,
      ];
}
