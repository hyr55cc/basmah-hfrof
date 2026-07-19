import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/level_repository.dart';
import '../repositories/leaderboard_repository.dart';
import '../repositories/achievement_repository.dart';
import '../repositories/shop_repository.dart';
import '../repositories/settings_repository.dart';
import '../entities/user.dart';
import '../entities/level.dart';
import '../entities/achievement.dart';
import '../entities/leaderboard.dart';
import '../entities/shop.dart';
import '../entities/settings.dart';

/// Base use case with parameters
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {
  const NoParams();
}

// ============================================================
// Auth use cases
// ============================================================

class SignInAnonymously implements UseCase<AuthResult, NoParams> {
  SignInAnonymously(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, AuthResult>> call(NoParams params) {
    return repository.signInAnonymously();
  }
}

class SignInWithGoogle implements UseCase<AuthResult, NoParams> {
  SignInWithGoogle(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, AuthResult>> call(NoParams params) {
    return repository.signInWithGoogle();
  }
}

class SignInWithApple implements UseCase<AuthResult, NoParams> {
  SignInWithApple(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, AuthResult>> call(NoParams params) {
    return repository.signInWithApple();
  }
}

class SignOut implements UseCase<void, NoParams> {
  SignOut(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.signOut();
  }
}

class GetCurrentUser implements UseCase<User?, NoParams> {
  GetCurrentUser(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, User?>> call(NoParams params) {
    return repository.getCurrentUser();
  }
}

class UpdateProfileParams {
  const UpdateProfileParams({this.displayName, this.photoUrl, this.country});
  final String? displayName;
  final String? photoUrl;
  final String? country;
}

class UpdateProfile implements UseCase<User, UpdateProfileParams> {
  UpdateProfile(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, User>> call(UpdateProfileParams params) {
    return repository.updateProfile(
      displayName: params.displayName,
      photoUrl: params.photoUrl,
      country: params.country,
    );
  }
}

// ============================================================
// User use cases
// ============================================================

class AddCoinsParams {
  const AddCoinsParams({required this.userId, required this.amount});
  final String userId;
  final int amount;
}

class AddCoins implements UseCase<User, AddCoinsParams> {
  AddCoins(this.repository);
  final UserRepository repository;

  @override
  Future<Either<Failure, User>> call(AddCoinsParams params) {
    return repository.addCoins(params.userId, params.amount);
  }
}

class SpendCoinsParams {
  const SpendCoinsParams({required this.userId, required this.amount});
  final String userId;
  final int amount;
}

class SpendCoins implements UseCase<User, SpendCoinsParams> {
  SpendCoins(this.repository);
  final UserRepository repository;

  @override
  Future<Either<Failure, User>> call(SpendCoinsParams params) {
    return repository.spendCoins(params.userId, params.amount);
  }
}

class UnlockLevelParams {
  const UnlockLevelParams({required this.userId, required this.level});
  final String userId;
  final int level;
}

class UnlockLevel implements UseCase<User, UnlockLevelParams> {
  UnlockLevel(this.repository);
  final UserRepository repository;

  @override
  Future<Either<Failure, User>> call(UnlockLevelParams params) {
    return repository.unlockLevel(params.userId, params.level);
  }
}

// ============================================================
// Level use cases
// ============================================================

class GetLevelParams {
  const GetLevelParams(this.levelId);
  final int levelId;
}

class GetLevel implements UseCase<Level?, GetLevelParams> {
  GetLevel(this.repository);
  final LevelRepository repository;

  @override
  Future<Either<Failure, Level?>> call(GetLevelParams params) {
    return repository.getLevel(params.levelId);
  }
}

class GetLevelRangeParams {
  const GetLevelRangeParams({required this.start, required this.end});
  final int start;
  final int end;
}

class GetLevelRange implements UseCase<List<Level>, GetLevelRangeParams> {
  GetLevelRange(this.repository);
  final LevelRepository repository;

  @override
  Future<Either<Failure, List<Level>>> call(GetLevelRangeParams params) {
    return repository.getLevelRange(start: params.start, end: params.end);
  }
}

class SaveLevelProgressParams {
  const SaveLevelProgressParams(this.progress);
  final LevelProgress progress;
}

class SaveLevelProgress
    implements UseCase<LevelProgress, SaveLevelProgressParams> {
  SaveLevelProgress(this.repository);
  final LevelRepository repository;

  @override
  Future<Either<Failure, LevelProgress>> call(SaveLevelProgressParams params) {
    return repository.saveLevelProgress(params.progress);
  }
}

// ============================================================
// Leaderboard use cases
// ============================================================

class GetLeaderboardParams {
  const GetLeaderboardParams({
    required this.type,
    this.period = LeaderboardPeriod.allTime,
    this.limit = 100,
  });
  final LeaderboardType type;
  final LeaderboardPeriod period;
  final int limit;
}

class GetTopEntries
    implements UseCase<List<LeaderboardEntry>, GetLeaderboardParams> {
  GetTopEntries(this.repository);
  final LeaderboardRepository repository;

  @override
  Future<Either<Failure, List<LeaderboardEntry>>> call(
      GetLeaderboardParams params) {
    return repository.getTopEntries(
      type: params.type,
      period: params.period,
      limit: params.limit,
    );
  }
}

// ============================================================
// Achievement use cases
// ============================================================

class GetUserAchievementsParams {
  const GetUserAchievementsParams(this.userId);
  final String userId;
}

class GetUserAchievements
    implements UseCase<List<AchievementProgress>, GetUserAchievementsParams> {
  GetUserAchievements(this.repository);
  final AchievementRepository repository;

  @override
  Future<Either<Failure, List<AchievementProgress>>> call(
      GetUserAchievementsParams params) {
    return repository.getUserProgress(params.userId);
  }
}

class IncrementAchievementParams {
  const IncrementAchievementParams({
    required this.userId,
    required this.achievementId,
    required this.amount,
  });
  final String userId;
  final String achievementId;
  final int amount;
}

class IncrementAchievement
    implements UseCase<AchievementProgress, IncrementAchievementParams> {
  IncrementAchievement(this.repository);
  final AchievementRepository repository;

  @override
  Future<Either<Failure, AchievementProgress>> call(
      IncrementAchievementParams params) {
    return repository.incrementProgress(
      userId: params.userId,
      achievementId: params.achievementId,
      amount: params.amount,
    );
  }
}

// ============================================================
// Shop use cases
// ============================================================

class GetShopItems implements UseCase<List<ShopItem>, NoParams> {
  GetShopItems(this.repository);
  final ShopRepository repository;

  @override
  Future<Either<Failure, List<ShopItem>>> call(NoParams params) {
    return repository.getShopItems();
  }
}

class GetDailyRewardStatusParams {
  const GetDailyRewardStatusParams(this.userId);
  final String userId;
}

class GetDailyRewardStatus
    implements UseCase<DailyRewardStatus, GetDailyRewardStatusParams> {
  GetDailyRewardStatus(this.repository);
  final ShopRepository repository;

  @override
  Future<Either<Failure, DailyRewardStatus>> call(
      GetDailyRewardStatusParams params) {
    return repository.getDailyRewardStatus(params.userId);
  }
}

class ClaimDailyRewardParams {
  const ClaimDailyRewardParams(this.userId);
  final String userId;
}

class ClaimDailyReward
    implements UseCase<DailyReward, ClaimDailyRewardParams> {
  ClaimDailyReward(this.repository);
  final ShopRepository repository;

  @override
  Future<Either<Failure, DailyReward>> call(ClaimDailyRewardParams params) {
    return repository.claimDailyReward(params.userId);
  }
}

// ============================================================
// Settings use cases
// ============================================================

class GetSettings implements UseCase<AppSettings, NoParams> {
  GetSettings(this.repository);
  final SettingsRepository repository;

  @override
  Future<Either<Failure, AppSettings>> call(NoParams params) {
    return repository.getSettings();
  }
}

class UpdateSettingsParams {
  const UpdateSettingsParams(this.settings);
  final AppSettings settings;
}

class UpdateSettings implements UseCase<AppSettings, UpdateSettingsParams> {
  UpdateSettings(this.repository);
  final SettingsRepository repository;

  @override
  Future<Either<Failure, AppSettings>> call(UpdateSettingsParams params) {
    return repository.updateSettings(params.settings);
  }
}
