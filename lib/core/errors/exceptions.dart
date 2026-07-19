/// Base exception class for the app
sealed class AppException implements Exception {
  const AppException(this.message, [this.code]);
  final String message;
  final String? code;

  @override
  String toString() => 'AppException: $message';
}

/// Server-related exceptions
class ServerException extends AppException {
  const ServerException(super.message, [super.code]);
}

/// Network-related exceptions
class NetworkException extends AppException {
  const NetworkException(super.message, [super.code]);
}

/// Cache-related exceptions
class CacheException extends AppException {
  const CacheException(super.message, [super.code]);
}

/// Authentication-related exceptions
class AuthException extends AppException {
  const AuthException(super.message, [super.code]);
}

/// Validation-related exceptions
class ValidationException extends AppException {
  const ValidationException(super.message, [super.code]);
}

/// Not found exceptions
class NotFoundException extends AppException {
  const NotFoundException(super.message, [super.code]);
}

/// Rate limit exceeded
class RateLimitException extends AppException {
  const RateLimitException(super.message, [super.code]);
}

/// Permission denied
class PermissionDeniedException extends AppException {
  const PermissionDeniedException(super.message, [super.code]);
}

/// In-app purchase related
class PurchaseException extends AppException {
  const PurchaseException(super.message, [super.code]);
}

/// Ad-related
class AdException extends AppException {
  const AdException(super.message, [super.code]);
}

/// Word validation
class InvalidWordException extends AppException {
  const InvalidWordException(super.message, [super.code]);
}

/// Game logic
class GameException extends AppException {
  const GameException(super.message, [super.code]);
}

/// Generic fallback
class UnknownException extends AppException {
  const UnknownException(super.message, [super.code]);
}
