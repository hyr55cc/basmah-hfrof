import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/achievement.dart';

abstract class AchievementRepository {
  /// Get all achievements definitions
  Future<Either<Failure, List<Achievement>>> getAllAchievements();

  /// Get user's progress on all achievements
  Future<Either<Failure, List<AchievementProgress>>> getUserProgress(
    String userId,
  );

  /// Update progress on an achievement
  Future<Either<Failure, AchievementProgress>> updateProgress({
    required String userId,
    required String achievementId,
    required int current,
  });

  /// Increment progress by an amount
  Future<Either<Failure, AchievementProgress>> incrementProgress({
    required String userId,
    required String achievementId,
    required int amount,
  });

  /// Claim a completed achievement reward
  Future<Either<Failure, int>> claimReward({
    required String userId,
    required String achievementId,
  });

  /// Get stream of progress updates
  Stream<List<AchievementProgress>> get progressStream;

  /// Mark all as seen
  Future<Either<Failure, void>> markAllAsSeen(String userId);

  /// Get unseen achievements
  Future<Either<Failure, List<AchievementProgress>>> getUnseen(String userId);
}
