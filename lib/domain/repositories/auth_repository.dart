import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user.dart';

/// Auth repository interface
abstract class AuthRepository {
  /// Get current authenticated user
  Future<Either<Failure, User?>> getCurrentUser();

  /// Stream of auth state changes
  Stream<User?> get authStateChanges;

  /// Sign in with Google
  Future<Either<Failure, AuthResult>> signInWithGoogle();

  /// Sign in with Apple
  Future<Either<Failure, AuthResult>> signInWithApple();

  /// Sign in as guest / anonymous
  Future<Either<Failure, AuthResult>> signInAnonymously();

  /// Sign in with email & password
  Future<Either<Failure, AuthResult>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Register with email & password
  Future<Either<Failure, AuthResult>> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  });

  /// Reset password
  Future<Either<Failure, void>> resetPassword(String email);

  /// Sign out
  Future<Either<Failure, void>> signOut();

  /// Update user profile
  Future<Either<Failure, User>> updateProfile({
    String? displayName,
    String? photoUrl,
    String? country,
  });

  /// Delete account
  Future<Either<Failure, void>> deleteAccount();
}
