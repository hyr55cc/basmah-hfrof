import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/level.dart';

abstract class LevelRepository {
  /// Get a single level by ID
  Future<Either<Failure, Level?>> getLevel(int levelId);

  /// Get multiple levels by IDs
  Future<Either<Failure, List<Level>>> getLevels(List<int> levelIds);

  /// Get a range of levels
  Future<Either<Failure, List<Level>>> getLevelRange({
    required int start,
    required int end,
  });

  /// Get next batch of levels (pagination)
  Future<Either<Failure, List<Level>>> getLevelsPaginated({
    int? lastLevelId,
    int limit = 20,
  });

  /// Get random levels
  Future<Either<Failure, List<Level>>> getRandomLevels({int count = 10});

  /// Search levels by difficulty
  Future<Either<Failure, List<Level>>> getLevelsByDifficulty(
    LevelDifficulty difficulty,
  );

  /// Get progress for a level
  Future<Either<Failure, LevelProgress?>> getLevelProgress(int levelId);

  /// Get all level progress for current user
  Future<Either<Failure, Map<int, LevelProgress>>> getAllLevelProgress();

  /// Save level progress
  Future<Either<Failure, LevelProgress>> saveLevelProgress(
    LevelProgress progress,
  );

  /// Stream of level progress
  Stream<Map<int, LevelProgress>> get progressStream;

  /// Add a new level (admin)
  Future<Either<Failure, Level>> addLevel(Level level);

  /// Update level (admin)
  Future<Either<Failure, Level>> updateLevel(Level level);

  /// Delete level (admin)
  Future<Either<Failure, void>> deleteLevel(int levelId);

  /// Pre-cache levels for offline play
  Future<Either<Failure, void>> cacheLevels(List<Level> levels);

  /// Clear cache
  Future<Either<Failure, void>> clearCache();
}
