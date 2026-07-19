import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/leaderboard.dart';
import '../../domain/repositories/leaderboard_repository.dart';
import '../datasources/local/local_storage.dart';
import '../datasources/remote/firebase_datasource.dart';
import '../models/leaderboard_model.dart';

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  LeaderboardRepositoryImpl({
    required this.firebase,
    required this.storage,
  });

  final FirebaseDatasource firebase;
  final LocalStorage storage;

  String _collectionName(LeaderboardType type, LeaderboardPeriod period) {
    final periodName = period == LeaderboardPeriod.allTime
        ? 'all'
        : period == LeaderboardPeriod.daily
            ? 'daily'
            : period == LeaderboardPeriod.weekly
                ? 'weekly'
                : 'monthly';
    return '${type.collectionName}_$periodName';
  }

  @override
  Future<Either<Failure, List<LeaderboardEntry>>> getTopEntries({
    required LeaderboardType type,
    LeaderboardPeriod period = LeaderboardPeriod.allTime,
    int limit = 100,
  }) async {
    try {
      final collection = _collectionName(type, period);
      final entries = await firebase.getLeaderboard(
        collection: collection,
        limit: limit,
      );
      final currentUserId = firebase.currentFirebaseUser?.uid;
      return Right(entries.map((e) {
        final entry = LeaderboardEntryModel.fromEntity(e);
        if (currentUserId != null && entry.userId == currentUserId) {
          return LeaderboardEntryModel.fromEntity(
            LeaderboardEntry(
              userId: entry.userId,
              displayName: entry.displayName,
              score: entry.score,
              rank: entry.rank,
              photoUrl: entry.photoUrl,
              country: entry.country,
              avatar: entry.avatar,
              isCurrentUser: true,
            ),
          );
        }
        return entry;
      }).toList());
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<LeaderboardEntry>>> getNearbyEntries({
    required LeaderboardType type,
    LeaderboardPeriod period = LeaderboardPeriod.allTime,
    int range = 10,
  }) async {
    try {
      final collection = _collectionName(type, period);
      final all = await firebase.getLeaderboard(
        collection: collection,
        limit: 1000,
      );
      final currentUserId = firebase.currentFirebaseUser?.uid;
      if (currentUserId == null) {
        return Right(all.take(range * 2).toList());
      }
      final currentIndex = all.indexWhere((e) => e.userId == currentUserId);
      if (currentIndex == -1) {
        return Right(all.take(range).toList());
      }
      final start = (currentIndex - range).clamp(0, all.length);
      final end = (currentIndex + range).clamp(0, all.length);
      return Right(all.sublist(start, end));
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, LeaderboardEntry?>> getCurrentUserEntry({
    required LeaderboardType type,
    LeaderboardPeriod period = LeaderboardPeriod.allTime,
  }) async {
    try {
      final userId = firebase.currentFirebaseUser?.uid;
      if (userId == null) return const Right(null);
      final all = await getTopEntries(type: type, period: period, limit: 1000);
      return all.fold((failure) => Left(failure), (entries) {
        final found = entries.where((e) => e.userId == userId).toList();
        return Right(found.isEmpty ? null : found.first);
      });
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> submitScore({
    required String userId,
    required String displayName,
    required int score,
    required LeaderboardType type,
    String? photoUrl,
    String? country,
  }) async {
    try {
      for (final period in LeaderboardPeriod.values) {
        final collection = _collectionName(type, period);
        await firebase.submitLeaderboardEntry(
          collection: collection,
          userId: userId,
          displayName: displayName,
          score: score,
          photoUrl: photoUrl,
          country: country,
        );
      }
      return const Right(null);
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<LeaderboardEntry>>> getFriendsLeaderboard({
    required LeaderboardType type,
    required List<String> friendIds,
  }) async {
    try {
      final collection = _collectionName(type, LeaderboardPeriod.allTime);
      final all = await firebase.getLeaderboard(collection: collection);
      final friendEntries = all
          .where((e) => friendIds.contains(e.userId))
          .toList();
      return Right(friendEntries);
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> resetLeaderboard(LeaderboardType type) async {
    try {
      for (final period in LeaderboardPeriod.values) {
        final collection = _collectionName(type, period);
        await firebase.resetLeaderboard(collection);
      }
      return const Right(null);
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  Failure _mapFailure(AppException e) {
    if (e is NetworkException) return NetworkFailure(e.message);
    if (e is ServerException) return ServerFailure(e.message);
    if (e is AuthException) return AuthFailure(e.message);
    return UnknownFailure(e.message);
  }
}
