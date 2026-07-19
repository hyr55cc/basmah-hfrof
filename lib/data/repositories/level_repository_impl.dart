import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/level.dart';
import '../../domain/repositories/level_repository.dart';
import '../datasources/local/local_storage.dart';
import '../datasources/remote/firebase_datasource.dart';
import '../models/level_model.dart';

class LevelRepositoryImpl implements LevelRepository {
  LevelRepositoryImpl({
    required this.firebase,
    required this.storage,
  });

  final FirebaseDatasource firebase;
  final LocalStorage storage;

  @override
  Future<Either<Failure, Level?>> getLevel(int levelId) async {
    try {
      // Try cache first
      final cached = storage.getCachedLevel(levelId);
      if (cached != null) {
        return Right(LevelModel.fromMap(cached));
      }
      // Fetch from Firestore
      final level = await firebase.getLevel(levelId);
      if (level != null) {
        await storage.cacheLevel(levelId, level.toMap());
      }
      return Right(level);
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<Level>>> getLevels(List<int> levelIds) async {
    try {
      final levels = <Level>[];
      for (final id in levelIds) {
        final result = await getLevel(id);
        result.fold((_) => null, (level) {
          if (level != null) levels.add(level);
        });
      }
      return Right(levels);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Level>>> getLevelRange({
    required int start,
    required int end,
  }) async {
    try {
      final levels = await firebase.getLevelRange(start: start, end: end);
      // Cache for offline
      for (final level in levels) {
        await storage.cacheLevel(level.id, level.toMap());
      }
      return Right(levels.cast<Level>());
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<Level>>> getLevelsPaginated({
    int? lastLevelId,
    int limit = 20,
  }) async {
    try {
      final levels = await firebase.getLevelsPaginated(
        lastLevelId: lastLevelId,
        limit: limit,
      );
      return Right(levels.cast<Level>());
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<Level>>> getRandomLevels({int count = 10}) async {
    try {
      // Get a range and shuffle
      final start = 1;
      final end = count * 2;
      final result = await firebase.getLevelRange(start: start, end: end);
      result.shuffle();
      return Right(result.take(count).toList());
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<Level>>> getLevelsByDifficulty(
    LevelDifficulty difficulty,
  ) async {
    try {
      final result = await firebase.getLevelsPaginated(limit: 1000);
      final filtered = result.where((l) => l.difficulty == difficulty).toList();
      return Right(filtered.cast<Level>());
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, LevelProgress?>> getLevelProgress(int levelId) async {
    try {
      final userId = firebase.currentFirebaseUser?.uid;
      if (userId == null) return const Right(null);
      final progress = await firebase.getLevelProgress(userId, levelId);
      return Right(progress);
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, Map<int, LevelProgress>>> getAllLevelProgress() async {
    try {
      final userId = firebase.currentFirebaseUser?.uid;
      if (userId == null) return const Right(<int, LevelProgress>{});
      final progress = await firebase.getAllLevelProgress(userId);
      return Right(progress.cast<int, LevelProgress>());
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, LevelProgress>> saveLevelProgress(
    LevelProgress progress,
  ) async {
    try {
      final userId = firebase.currentFirebaseUser?.uid;
      if (userId == null) {
        return const Left(AuthFailure('غير مسجل دخول'));
      }
      final model = LevelProgressModel.fromEntity(progress);
      await firebase.saveLevelProgress(userId, model);
      return Right(progress);
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Stream<Map<int, LevelProgress>> get progressStream {
    final userId = firebase.currentFirebaseUser?.uid;
    if (userId == null) {
      return const Stream<Map<int, LevelProgress>>.empty();
    }
    return firebase.progressStream(userId).map((m) => m.cast<int, LevelProgress>());
  }

  @override
  Future<Either<Failure, Level>> addLevel(Level level) async {
    try {
      final model = LevelModel.fromEntity(level);
      await firebase.upsertLevel(model);
      return Right(level);
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, Level>> updateLevel(Level level) async {
    try {
      final model = LevelModel.fromEntity(level);
      await firebase.upsertLevel(model);
      return Right(level);
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLevel(int levelId) async {
    try {
      await firebase.deleteLevel(levelId);
      await storage.deleteBoxData('levels_box', 'level_$levelId');
      return const Right(null);
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> cacheLevels(List<Level> levels) async {
    try {
      for (final level in levels) {
        await storage.cacheLevel(level.id, LevelModel.fromEntity(level).toMap());
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearCache() async {
    try {
      await storage.clearBox('levels_box');
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  Failure _mapFailure(AppException e) {
    if (e is NetworkException) return NetworkFailure(e.message);
    if (e is ServerException) return ServerFailure(e.message);
    if (e is CacheException) return CacheFailure(e.message);
    if (e is AuthException) return AuthFailure(e.message);
    if (e is ValidationException) return ValidationFailure(e.message);
    if (e is NotFoundException) return NotFoundFailure(e.message);
    return UnknownFailure(e.message);
  }
}
