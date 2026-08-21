class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException([this.message = 'An error occurred', this.statusCode]);

  @override
  String toString() => 'AppException: $message (code: $statusCode)';
}

class ServerException extends AppException {
  const ServerException([super.message = 'Server error occurred', super.statusCode = 500]);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Resource not found', super.statusCode = 404]);
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Network connection failed', super.statusCode = 0]);
}

class TimeoutException extends AppException {
  const TimeoutException([super.message = 'Request timed out', super.statusCode = 408]);
}

class AuthException extends AppException {
  const AuthException([super.message = 'Authentication failed', super.statusCode = 401]);
}

class PermissionException extends AppException {
  const PermissionException([super.message = 'Action unauthorized for your role', super.statusCode = 403]);
}

class ValidationException extends AppException {
  const ValidationException([super.message = 'Validation failed', super.statusCode = 422]);
}
