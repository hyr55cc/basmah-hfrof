import 'package:get_it/get_it.dart';
import '../network/api_client.dart';
import '../../data/datasources/local/local_storage.dart';
import '../../data/datasources/remote/firebase_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/level_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/repositories/leaderboard_repository_impl.dart';
import '../../data/repositories/achievement_repository_impl.dart';
import '../../data/repositories/shop_repository_impl.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/level_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/leaderboard_repository.dart';
import '../../domain/repositories/achievement_repository.dart';
import '../../domain/repositories/shop_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../services/analytics/analytics_service.dart';
import '../../services/audio/audio_service.dart';
import '../../services/haptics/haptic_service.dart';
import '../../services/notifications/notification_service.dart';
import '../../services/ads/ad_service.dart';
import '../../services/iap/purchase_service.dart';
import '../../services/storage/storage_service.dart';

/// Service locator instance
final GetIt sl = GetIt.instance;

/// Initialize all dependencies
Future<void> initDependencies() async {
  // Core
  sl.registerLazySingleton<ApiClient>(() => ApiClient());
  sl.registerLazySingleton<LocalStorage>(() => LocalStorage());
  sl.registerLazySingleton<StorageService>(() => StorageService());

  // Services
  sl.registerLazySingleton<AnalyticsService>(() => AnalyticsService());
  sl.registerLazySingleton<AudioService>(() => AudioService());
  sl.registerLazySingleton<HapticService>(() => HapticService());
  sl.registerLazySingleton<NotificationService>(() => NotificationService());
  sl.registerLazySingleton<AdService>(() => AdService());
  sl.registerLazySingleton<PurchaseService>(() => PurchaseService());

  // Data sources
  sl.registerLazySingleton<FirebaseDatasource>(() => FirebaseDatasource());

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      firebase: sl<FirebaseDatasource>(),
      storage: sl<LocalStorage>(),
      analytics: sl<AnalyticsService>(),
    ),
  );
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      firebase: sl<FirebaseDatasource>(),
      storage: sl<LocalStorage>(),
    ),
  );
  sl.registerLazySingleton<LevelRepository>(
    () => LevelRepositoryImpl(
      firebase: sl<FirebaseDatasource>(),
      storage: sl<LocalStorage>(),
    ),
  );
  sl.registerLazySingleton<LeaderboardRepository>(
    () => LeaderboardRepositoryImpl(
      firebase: sl<FirebaseDatasource>(),
      storage: sl<LocalStorage>(),
    ),
  );
  sl.registerLazySingleton<AchievementRepository>(
    () => AchievementRepositoryImpl(
      firebase: sl<FirebaseDatasource>(),
      storage: sl<LocalStorage>(),
    ),
  );
  sl.registerLazySingleton<ShopRepository>(
    () => ShopRepositoryImpl(
      firebase: sl<FirebaseDatasource>(),
      storage: sl<LocalStorage>(),
      purchase: sl<PurchaseService>(),
    ),
  );
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(
      storage: sl<LocalStorage>(),
    ),
  );
}
