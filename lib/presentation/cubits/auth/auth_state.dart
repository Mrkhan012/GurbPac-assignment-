import 'package:equatable/equatable.dart';
import '../../../domain/entities/auth_token.dart';
import '../../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {
  final String? message;
  const AuthLoading([this.message]);

  @override
  List<Object?> get props => [message];
}

class Authenticated extends AuthState {
  final User user;
  final AuthToken? token;
  final bool isRefreshing;

  const Authenticated({
    required this.user,
    this.token,
    this.isRefreshing = false,
  });

  Authenticated copyWith({
    User? user,
    AuthToken? token,
    bool? isRefreshing,
  }) {
    return Authenticated(
      user: user ?? this.user,
      token: token ?? this.token,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [user, token, isRefreshing];
}

class Unauthenticated extends AuthState {
  final String? message;
  const Unauthenticated([this.message]);

  @override
  List<Object?> get props => [message];
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class SessionExpired extends AuthState {
  final String message;
  const SessionExpired([this.message = 'Session expired. Please log in again.']);

  @override
  List<Object?> get props => [message];
}
