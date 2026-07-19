import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/settings.dart';

abstract class SettingsRepository {
  /// Get current settings
  Future<Either<Failure, AppSettings>> getSettings();

  /// Update settings
  Future<Either<Failure, AppSettings>> updateSettings(AppSettings settings);

  /// Reset to defaults
  Future<Either<Failure, AppSettings>> resetToDefaults();

  /// Stream of settings changes
  Stream<AppSettings> get settingsStream;
}
