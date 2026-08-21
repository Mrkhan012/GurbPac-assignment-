import '../entities/auth_token.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<({User user, AuthToken token})> login({
    required String email,
    required String password,
  });

  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String orgId,
  });

  Future<AuthToken> refreshToken(String refreshToken);

  Future<User?> getCurrentUser();

  Future<void> logout();

  Future<bool> isAuthenticated();
}
