import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../domain/entities/user.dart';
import '../../../../domain/repositories/auth_repository.dart';
import '../../../../domain/usecases/usecases.dart';

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
