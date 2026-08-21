import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/failures.dart';
import '../../../core/services/storage_service.dart';
import '../../../domain/usecases/auth_usecases.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthUseCases _authUseCases;
  final StorageService _storageService;

  AuthCubit({
    required AuthUseCases authUseCases,
    required StorageService storageService,
  })  : _authUseCases = authUseCases,
        _storageService = storageService,
        super(AuthInitial());

  Future<void> checkAuthSession() async {
    emit(const AuthLoading('Checking session...'));
    try {
      final user = await _authUseCases.getCurrentUser();
      final hasValidToken = await _authUseCases.isAuthenticated();

      if (user != null && hasValidToken) {
        emit(Authenticated(user: user));
      } else {
        emit(const Unauthenticated());
      }
    } catch (_) {
      emit(const Unauthenticated());
    }
  }

  Future<void> login({required String email, required String password}) async {
    emit(const AuthLoading('Signing in...'));
    try {
      final result = await _authUseCases.login(email: email, password: password);
      emit(Authenticated(user: result.user, token: result.token));
    } on Failure catch (f) {
      emit(AuthError(f.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String orgId,
  }) async {
    emit(const AuthLoading('Creating account...'));
    try {
      final user = await _authUseCases.register(
        name: name,
        email: email,
        password: password,
        orgId: orgId,
      );
      emit(Authenticated(user: user));
    } on Failure catch (f) {
      emit(AuthError(f.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> refreshSessionToken() async {
    final currentState = state;
    if (currentState is! Authenticated) return;

    emit(currentState.copyWith(isRefreshing: true));
    try {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        emit(const SessionExpired());
        return;
      }
      final newToken = await _authUseCases.refreshToken(refreshToken);
      emit(Authenticated(user: currentState.user, token: newToken, isRefreshing: false));
    } catch (_) {
      emit(const SessionExpired());
    }
  }

  Future<void> logout() async {
    emit(const AuthLoading('Logging out...'));
    await _authUseCases.logout();
    emit(const Unauthenticated());
  }
}
