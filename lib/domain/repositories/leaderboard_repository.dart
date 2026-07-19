import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/leaderboard.dart';

abstract class LeaderboardRepository {
  /// Get top entries for a leaderboard
  Future<Either<Failure, List<LeaderboardEntry>>> getTopEntries({
    required LeaderboardType type,
    LeaderboardPeriod period = LeaderboardPeriod.allTime,
    int limit = 100,
  });

  /// Get entries around the current user
  Future<Either<Failure, List<LeaderboardEntry>>> getNearbyEntries({
    required LeaderboardType type,
    LeaderboardPeriod period = LeaderboardPeriod.allTime,
    int range = 10,
  });

  /// Get current user's entry
  Future<Either<Failure, LeaderboardEntry?>> getCurrentUserEntry({
    required LeaderboardType type,
    LeaderboardPeriod period = LeaderboardPeriod.allTime,
  });

  /// Submit score to leaderboard
  Future<Either<Failure, void>> submitScore({
    required String userId,
    required String displayName,
    required int score,
    required LeaderboardType type,
    String? photoUrl,
    String? country,
  });

  /// Get friends' leaderboard
  Future<Either<Failure, List<LeaderboardEntry>>> getFriendsLeaderboard({
    required LeaderboardType type,
    required List<String> friendIds,
  });

  /// Reset daily / weekly leaderboard (admin)
  Future<Either<Failure, void>> resetLeaderboard(LeaderboardType type);
}
