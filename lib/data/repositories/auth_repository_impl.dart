import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/services/storage_service.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/mock_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final MockDataSource _dataSource;
  final StorageService _storageService;

  AuthRepositoryImpl({
    required MockDataSource dataSource,
    required StorageService storageService,
  })  : _dataSource = dataSource,
        _storageService = storageService;

  @override
  Future<({User user, AuthToken token})> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _dataSource.login(email: email, password: password);

      await _storageService.setAccessToken(result.token.accessToken);
      await _storageService.setRefreshToken(result.token.refreshToken);
      await _storageService.setTokenExpiry(result.token.expiryTime);
      await _storageService.saveCurrentUserData(result.user.toJson());

      return (user: result.user, token: result.token);
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on TimeoutException catch (e) {
      throw TimeoutFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String orgId,
  }) async {
    try {
      final user = await _dataSource.register(
        name: name,
        email: email,
        password: password,
        orgId: orgId,
      );
      return user;
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<AuthToken> refreshToken(String refreshToken) async {
    try {
      final token = await _dataSource.refreshToken(refreshToken);
      await _storageService.setAccessToken(token.accessToken);
      await _storageService.setRefreshToken(token.refreshToken);
      await _storageService.setTokenExpiry(token.expiryTime);
      return token;
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final userData = _storageService.getCurrentUserData();
      if (userData != null) {
        return UserModel.fromJson(userData);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await _storageService.clearAuthData();
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await _storageService.getAccessToken();
    if (token == null || token.isEmpty) return false;
    final expiry = await _storageService.getTokenExpiry();
    if (expiry != null && DateTime.now().isAfter(expiry)) {
      final refreshTokenStr = await _storageService.getRefreshToken();
      if (refreshTokenStr != null && refreshTokenStr.isNotEmpty) {
        try {
          await refreshToken(refreshTokenStr);
          return true;
        } catch (_) {
          await logout();
          return false;
        }
      }
      return false;
    }
    return true;
  }
}
