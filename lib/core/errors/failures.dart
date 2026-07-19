import 'package:equatable/equatable.dart';

/// Base failure class for returning errors from use cases
sealed class Failure extends Equatable {
  const Failure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

/// Server-side failure
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Network failure (no internet, timeout, etc.)
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Local cache failure
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Auth failure
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Validation failure (input errors)
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Not found
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// Rate limit
class RateLimitFailure extends Failure {
  const RateLimitFailure(super.message);
}

/// Permission denied
class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

/// IAP failure
class PurchaseFailure extends Failure {
  const PurchaseFailure(super.message);
}

/// Ad failure
class AdFailure extends Failure {
  const AdFailure(super.message);
}

/// Game / domain logic failure
class GameFailure extends Failure {
  const GameFailure(super.message);
}

/// Unknown / unexpected failure
class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
