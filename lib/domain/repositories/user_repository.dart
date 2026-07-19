import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class UserRepository {
  /// Get user data
  Future<Either<Failure, User>> getUser(String userId);

  /// Get user data stream
  Stream<User> getUserStream(String userId);

  /// Update user
  Future<Either<Failure, User>> updateUser(User user);

  /// Add coins
  Future<Either<Failure, User>> addCoins(String userId, int amount);

  /// Spend coins (returns failure if insufficient)
  Future<Either<Failure, User>> spendCoins(String userId, int amount);

  /// Add gems
  Future<Either<Failure, User>> addGems(String userId, int amount);

  /// Add hints
  Future<Either<Failure, User>> addHints(String userId, int amount);

  /// Use hint
  Future<Either<Failure, User>> useHint(String userId);

  /// Update level progress
  Future<Either<Failure, User>> updateLevelProgress({
    required String userId,
    required int newLevel,
    int? score,
    int? wordsFound,
  });

  /// Unlock level
  Future<Either<Failure, User>> unlockLevel(String userId, int level);

  /// Set premium status
  Future<Either<Failure, User>> setPremium(
    String userId, {
    required bool isPremium,
    DateTime? expiryDate,
  });

  /// Update stats
  Future<Either<Failure, User>> updateStats({
    required String userId,
    int? totalScore,
    int? totalWordsFound,
    int? totalBonusWords,
  });

  /// Ban user (admin)
  Future<Either<Failure, void>> banUser(String userId, {String? reason});

  /// Get all users (admin)
  Future<Either<Failure, List<User>>> getAllUsers({
    int limit = 50,
    String? startAfter,
  });

  /// Search users
  Future<Either<Failure, List<User>>> searchUsers(String query);
}
