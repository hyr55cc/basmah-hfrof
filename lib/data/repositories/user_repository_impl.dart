import 'package:dartz/dartz.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/local/local_storage.dart';
import '../datasources/remote/firebase_datasource.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({
    required this.firebase,
    required this.storage,
  });

  final FirebaseDatasource firebase;
  final LocalStorage storage;

  @override
  Future<Either<Failure, User>> getUser(String userId) async {
    try {
      final user = await firebase.getUser(userId);
      if (user == null) {
        return const Left(NotFoundFailure('المستخدم غير موجود'));
      }
      return Right(user);
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Stream<User> getUserStream(String userId) {
    return firebase.getUserStream(userId).where((u) => u != null).cast<User>();
  }

  @override
  Future<Either<Failure, User>> updateUser(User user) async {
    try {
      final model = UserModel.fromEntity(user);
      await firebase.updateUserDocument(model);
      await storage.cacheUserData(model.toMap());
      return Right(user);
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, User>> addCoins(String userId, int amount) async {
    try {
      final user = await firebase.getUser(userId);
      if (user == null) return const Left(NotFoundFailure('المستخدم غير موجود'));
      final updated = user.copyWith(coins: user.coins + amount);
      await firebase.updateUserDocument(UserModel.fromEntity(updated));
      return Right(updated);
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, User>> spendCoins(String userId, int amount) async {
    try {
      final user = await firebase.getUser(userId);
      if (user == null) return const Left(NotFoundFailure('المستخدم غير موجود'));
      if (user.coins < amount) {
        return const Left(ValidationFailure('عملات غير كافية'));
      }
      final updated = user.copyWith(coins: user.coins - amount);
      await firebase.updateUserDocument(UserModel.fromEntity(updated));
      return Right(updated);
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, User>> addGems(String userId, int amount) async {
    try {
      final user = await firebase.getUser(userId);
      if (user == null) return const Left(NotFoundFailure('المستخدم غير موجود'));
      final updated = user.copyWith(gems: user.gems + amount);
      await firebase.updateUserDocument(UserModel.fromEntity(updated));
      return Right(updated);
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, User>> addHints(String userId, int amount) async {
    try {
      final user = await firebase.getUser(userId);
      if (user == null) return const Left(NotFoundFailure('المستخدم غير موجود'));
      final updated = user.copyWith(hints: user.hints + amount);
      await firebase.updateUserDocument(UserModel.fromEntity(updated));
      return Right(updated);
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, User>> useHint(String userId) async {
    try {
      final user = await firebase.getUser(userId);
      if (user == null) return const Left(NotFoundFailure('المستخدم غير موجود'));
      if (user.hints <= 0 && user.coins < AppConstants.hintRevealLetterCost) {
        return const Left(ValidationFailure('تلميحات وعملات غير كافية'));
      }
      User updated;
      if (user.hints > 0) {
        updated = user.copyWith(hints: user.hints - 1);
      } else {
        updated = user.copyWith(
          coins: user.coins - AppConstants.hintRevealLetterCost,
        );
      }
      await firebase.updateUserDocument(UserModel.fromEntity(updated));
      return Right(updated);
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, User>> updateLevelProgress({
    required String userId,
    required int newLevel,
    int? score,
    int? wordsFound,
  }) async {
    try {
      final user = await firebase.getUser(userId);
      if (user == null) return const Left(NotFoundFailure('المستخدم غير موجود'));
      final updated = user.copyWith(
        currentLevel: newLevel,
        maxUnlockedLevel:
            newLevel > user.maxUnlockedLevel ? newLevel : user.maxUnlockedLevel,
        totalScore: (user.totalScore + (score ?? 0)),
        totalWordsFound: (user.totalWordsFound + (wordsFound ?? 0)),
      );
      await firebase.updateUserDocument(UserModel.fromEntity(updated));
      return Right(updated);
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, User>> unlockLevel(String userId, int level) async {
    try {
      final user = await firebase.getUser(userId);
      if (user == null) return const Left(NotFoundFailure('المستخدم غير موجود'));
      if (level <= user.maxUnlockedLevel) return Right(user);
      final updated = user.copyWith(maxUnlockedLevel: level);
      await firebase.updateUserDocument(UserModel.fromEntity(updated));
      return Right(updated);
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, User>> setPremium(
    String userId, {
    required bool isPremium,
    DateTime? expiryDate,
  }) async {
    try {
      final user = await firebase.getUser(userId);
      if (user == null) return const Left(NotFoundFailure('المستخدم غير موجود'));
      final updated = user.copyWith(
        isPremium: isPremium,
        premiumExpiryDate: expiryDate,
      );
      await firebase.updateUserDocument(UserModel.fromEntity(updated));
      return Right(updated);
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, User>> updateStats({
    required String userId,
    int? totalScore,
    int? totalWordsFound,
    int? totalBonusWords,
  }) async {
    try {
      final user = await firebase.getUser(userId);
      if (user == null) return const Left(NotFoundFailure('المستخدم غير موجود'));
      final updated = user.copyWith(
        totalScore: totalScore ?? user.totalScore,
        totalWordsFound: totalWordsFound ?? user.totalWordsFound,
        totalBonusWords: totalBonusWords ?? user.totalBonusWords,
      );
      await firebase.updateUserDocument(UserModel.fromEntity(updated));
      return Right(updated);
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> banUser(String userId, {String? reason}) async {
    try {
      await firebase.banUser(userId, reason: reason);
      return const Right(null);
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<User>>> getAllUsers({
    int limit = 50,
    String? startAfter,
  }) async {
    try {
      final users = await firebase.getAllUsers(limit: limit);
      return Right(users.cast<User>());
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<User>>> searchUsers(String query) async {
    try {
      final users = await firebase.searchUsers(query);
      return Right(users.cast<User>());
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    }
  }

  Failure _mapFailure(AppException e) {
    if (e is NetworkException) return NetworkFailure(e.message);
    if (e is ServerException) return ServerFailure(e.message);
    if (e is ValidationException) return ValidationFailure(e.message);
    if (e is NotFoundException) return NotFoundFailure(e.message);
    return UnknownFailure(e.message);
  }
}
