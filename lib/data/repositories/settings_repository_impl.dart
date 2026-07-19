import 'dart:convert';
import 'package:dartz/dartz.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/local/local_storage.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl({required this.storage});
  final LocalStorage storage;

  static const _settingsKey = 'app_settings';

  AppSettings _defaultSettings() => const AppSettings();

  @override
  Future<Either<Failure, AppSettings>> getSettings() async {
    try {
      final cached = storage.getBoxData<String>(
        AppConstants.settingsBox,
        _settingsKey,
      );
      if (cached != null) {
        return Right(AppSettings.fromJson(
          json.decode(cached) as Map<String, dynamic>,
        ));
      }
      return Right(_defaultSettings());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppSettings>> updateSettings(
    AppSettings settings,
  ) async {
    try {
      await storage.setBoxData(
        AppConstants.settingsBox,
        _settingsKey,
        json.encode(settings.toJson()),
      );
      return Right(settings);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppSettings>> resetToDefaults() async {
    return updateSettings(_defaultSettings());
  }

  @override
  Stream<AppSettings> get settingsStream async* {
    yield await getSettings().then((r) => r.fold((_) => _defaultSettings(), (s) => s));
    // No native stream - would need to add ChangeNotifier
  }
}

extension on AppSettings {
  Map<String, dynamic> toJson() => {
        'themeMode': themeMode.name,
        'language': language.name,
        'musicEnabled': musicEnabled,
        'soundEnabled': soundEnabled,
        'vibrationEnabled': vibrationEnabled,
        'notificationsEnabled': notificationsEnabled,
        'dailyReminderEnabled': dailyReminderEnabled,
        'eventReminderEnabled': eventReminderEnabled,
        'showAnimations': showAnimations,
        'hapticOnWordFound': hapticOnWordFound,
        'hapticOnLevelComplete': hapticOnLevelComplete,
        'adsRemoved': adsRemoved,
        'premiumMember': premiumMember,
        'dataSaverMode': dataSaverMode,
        'autoSync': autoSync,
        'analyticsEnabled': analyticsEnabled,
      };

  static AppSettings fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: _parseThemeMode(json['themeMode'] as String?),
      language: _parseLanguage(json['language'] as String?),
      musicEnabled: json['musicEnabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      dailyReminderEnabled: json['dailyReminderEnabled'] as bool? ?? true,
      eventReminderEnabled: json['eventReminderEnabled'] as bool? ?? true,
      showAnimations: json['showAnimations'] as bool? ?? true,
      hapticOnWordFound: json['hapticOnWordFound'] as bool? ?? true,
      hapticOnLevelComplete: json['hapticOnLevelComplete'] as bool? ?? true,
      adsRemoved: json['adsRemoved'] as bool? ?? false,
      premiumMember: json['premiumMember'] as bool? ?? false,
      dataSaverMode: json['dataSaverMode'] as bool? ?? false,
      autoSync: json['autoSync'] as bool? ?? true,
      analyticsEnabled: json['analyticsEnabled'] as bool? ?? true,
    );
  }

  static AppThemeMode _parseThemeMode(String? value) {
    switch (value) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      default:
        return AppThemeMode.system;
    }
  }

  static AppLanguage _parseLanguage(String? value) {
    switch (value) {
      case 'english':
        return AppLanguage.english;
      case 'french':
        return AppLanguage.french;
      case 'spanish':
        return AppLanguage.spanish;
      default:
        return AppLanguage.arabic;
    }
  }
}
