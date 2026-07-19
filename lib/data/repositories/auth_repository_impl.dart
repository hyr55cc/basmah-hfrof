import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/local_storage.dart';
import '../datasources/remote/firebase_datasource.dart';
import '../models/user_model.dart';
import '../../services/analytics/analytics_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.firebase,
    required this.storage,
    required this.analytics,
  });

  final FirebaseDatasource firebase;
  final LocalStorage storage;
  final AnalyticsService analytics;

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final cached = storage.getCachedUserData();
      if (cached != null) {
        return Right(UserModel.fromMap(cached));
      }
      final user = await firebase.getCurrentUser();
      if (user != null) {
        await storage.cacheUserData(user.toMap());
      }
      return Right(user);
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Stream<User?> get authStateChanges {
    return firebase.authStateChanges.asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      final user = await firebase.getUser(firebaseUser.uid);
      if (user != null) {
        await storage.cacheUserData(user.toMap());
      }
      return user;
    });
  }

  @override
  Future<Either<Failure, AuthResult>> signInWithGoogle() async {
    try {
      final cred = await firebase.signInWithGoogle();
      final user = await _ensureUserDocument(cred);
      await analytics.logLogin('google');
      return Right(AuthResult(user: user, isNewUser: cred.additionalUserInfo?.isNewUser ?? false));
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResult>> signInWithApple() async {
    try {
      final cred = await firebase.signInWithApple();
      final user = await _ensureUserDocument(cred);
      await analytics.logLogin('apple');
      return Right(AuthResult(user: user, isNewUser: cred.additionalUserInfo?.isNewUser ?? false));
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResult>> signInAnonymously() async {
    try {
      final cred = await firebase.signInAnonymously();
      final user = await _ensureUserDocument(cred);
      await analytics.logLogin('anonymous');
      return Right(AuthResult(user: user, isNewUser: cred.additionalUserInfo?.isNewUser ?? false));
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResult>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await firebase.signInWithEmail(email: email, password: password);
      final user = await _ensureUserDocument(cred);
      await analytics.logLogin('email');
      return Right(AuthResult(user: user, isNewUser: cred.additionalUserInfo?.isNewUser ?? false));
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResult>> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final cred = await firebase.createUserWithEmail(email: email, password: password);
      final user = await _ensureUserDocument(cred, displayName: displayName);
      await analytics.logSignUp('email');
      return Right(AuthResult(user: user, isNewUser: true));
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    try {
      await firebase.resetPassword(email);
      return const Right(null);
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await firebase.signOut();
      await storage.clearAllCache();
      await analytics.logLogout();
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    String? displayName,
    String? photoUrl,
    String? country,
  }) async {
    try {
      final current = await firebase.getCurrentUser();
      if (current == null) {
        return const Left(AuthFailure('غير مسجل دخول'));
      }
      final updated = current.copyWith(
        displayName: displayName ?? current.displayName,
        photoUrl: photoUrl ?? current.photoUrl,
        country: country ?? current.country,
      );
      await firebase.updateUserDocument(UserModel.fromEntity(updated));
      await storage.cacheUserData(UserModel.fromEntity(updated).toMap());
      return Right(updated);
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      await firebase.deleteAccount();
      await storage.clearAllCache();
      return const Right(null);
    } on AppException catch (e) {
      return Left(_mapFailure(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  Future<User> _ensureUserDocument(
    dynamic cred, {
    String? displayName,
  }) async {
    final firebaseUser = cred.user;
    if (firebaseUser == null) {
      throw const AuthException('فشل الحصول على معلومات المستخدم');
    }
    final existing = await firebase.getUser(firebaseUser.uid);
    if (existing != null) {
      // Update last login
      final updated = existing.copyWith(lastLoginAt: DateTime.now());
      await firebase.updateUserDocument(UserModel.fromEntity(updated));
      await storage.cacheUserData(UserModel.fromEntity(updated).toMap());
      return updated;
    }
    final newUser = UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? 'guest@anonymous.app',
      displayName: displayName ?? firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      isAnonymous: firebaseUser.isAnonymous,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
    await firebase.createUserDocument(newUser);
    await storage.cacheUserData(newUser.toMap());
    return newUser;
  }

  Failure _mapFailure(AppException e) {
    if (e is NetworkException) return NetworkFailure(e.message);
    if (e is ServerException) return ServerFailure(e.message);
    if (e is AuthException) return AuthFailure(e.message);
    if (e is CacheException) return CacheFailure(e.message);
    return UnknownFailure(e.message);
  }
}
