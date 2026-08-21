import '../entities/auth_token.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class AuthUseCases {
  final AuthRepository _repository;

  AuthUseCases(this._repository);

  Future<({User user, AuthToken token})> login({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }

  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String orgId,
  }) {
    return _repository.register(name: name, email: email, password: password, orgId: orgId);
  }

  Future<AuthToken> refreshToken(String refreshToken) {
    return _repository.refreshToken(refreshToken);
  }

  Future<User?> getCurrentUser() {
    return _repository.getCurrentUser();
  }

  Future<void> logout() {
    return _repository.logout();
  }

  Future<bool> isAuthenticated() {
    return _repository.isAuthenticated();
  }
}
