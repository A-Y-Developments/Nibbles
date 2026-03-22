sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => 'AppException: $message';
}

/// Thrown when there is no network connectivity.
final class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection.']);
}

/// Thrown on HTTP 5xx responses.
final class ServerException extends AppException {
  const ServerException([super.message = 'A server error occurred.']);
}

/// Thrown on HTTP 401 after a refresh retry — session is unrecoverable.
final class UnauthorizedException extends AppException {
  const UnauthorizedException([
    super.message = 'Session expired. Please log in again.',
  ]);
}

/// Thrown on HTTP 404.
final class NotFoundException extends AppException {
  const NotFoundException([
    super.message = 'The requested resource was not found.',
  ]);
}

/// Fallback for all other errors.
final class UnknownException extends AppException {
  const UnknownException([super.message = 'An unexpected error occurred.']);
}

/// Returned when a user attempts to log the same allergen twice in one day.
final class DuplicateLogException extends AppException {
  DuplicateLogException(String allergenName)
      : super(
          "You've already logged $allergenName today. "
          'Come back tomorrow for the next day.',
        );
}
