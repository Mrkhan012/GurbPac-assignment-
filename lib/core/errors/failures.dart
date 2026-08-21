import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure([this.message = 'An error occurred', this.statusCode]);

  @override
  List<Object?> get props => [message, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'An unexpected server error occurred.', super.statusCode = 500]);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'The requested resource was not found.', super.statusCode = 404]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection. Please check your network.', super.statusCode = 0]);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Connection timed out. Please try again.', super.statusCode = 408]);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Invalid email or password.', super.statusCode = 401]);
}

class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure([super.message = 'Your session has expired. Please log in again.', super.statusCode = 401]);
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'You do not have permission to perform this action.', super.statusCode = 403]);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Invalid input provided.', super.statusCode = 422]);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Failed to load cached data.', super.statusCode]);
}
