import 'package:flutter_test/flutter_test.dart';
import 'package:gurbpac/core/errors/failures.dart';
import 'package:gurbpac/core/network/simulation_manager.dart';
import 'package:gurbpac/core/services/storage_service.dart';
import 'package:gurbpac/data/datasources/mock_data_source_impl.dart';
import 'package:gurbpac/data/repositories/auth_repository_impl.dart';
import 'package:gurbpac/domain/usecases/auth_usecases.dart';

class FakeStorageService implements StorageService {
  String? accessToken;
  String? refreshToken;
  DateTime? tokenExpiry;
  Map<String, dynamic>? userData;
  bool isDark = false;
  final Map<String, dynamic> cache = {};

  @override
  Future<void> clearAll() async => clearAuthData();

  @override
  Future<void> clearAuthData() async {
    accessToken = null;
    refreshToken = null;
    tokenExpiry = null;
    userData = null;
  }

  @override
  Future<String?> getAccessToken() async => accessToken;

  @override
  dynamic getCachedData(String key) => cache[key];

  @override
  Map<String, dynamic>? getCurrentUserData() => userData;

  @override
  bool getDarkMode() => isDark;

  @override
  Future<String?> getRefreshToken() async => refreshToken;

  @override
  Future<DateTime?> getTokenExpiry() async => tokenExpiry;

  @override
  Future<void> saveCachedData(String key, dynamic data) async => cache[key] = data;

  @override
  Future<void> saveCurrentUserData(Map<String, dynamic> data) async => userData = data;

  @override
  Future<void> setAccessToken(String token) async => accessToken = token;

  @override
  Future<void> setDarkMode(bool isDark) async => this.isDark = isDark;

  @override
  Future<void> setRefreshToken(String token) async => refreshToken = token;

  @override
  Future<void> setTokenExpiry(DateTime expiry) async => tokenExpiry = expiry;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SimulationManager simulationManager;
  late FakeStorageService fakeStorageService;
  late MockDataSourceImpl mockDataSource;
  late AuthRepositoryImpl authRepository;
  late AuthUseCases authUseCases;

  setUp(() {
    simulationManager = SimulationManager()..delayMilliseconds = 0;
    fakeStorageService = FakeStorageService();
    mockDataSource = MockDataSourceImpl(
      simulationManager: simulationManager,
      storageService: fakeStorageService,
    );
    authRepository = AuthRepositoryImpl(
      dataSource: mockDataSource,
      storageService: fakeStorageService,
    );
    authUseCases = AuthUseCases(authRepository);
  });

  group('Authentication & Simulated Token Flow', () {
    test('Login with valid test credentials succeeds and stores tokens', () async {
      final result = await authUseCases.login(
        email: 'ava.admin@nimbusdigital.test',
        password: 'Password123!',
      );

      expect(result.user.id, 'user_001');
      expect(result.user.role, 'org_admin');
      expect(result.user.isAdmin, isTrue);
      expect(result.token.accessToken, isNotEmpty);
      expect(result.token.accessTokenExpiresInSeconds, 900);

      expect(fakeStorageService.accessToken, result.token.accessToken);
      expect(fakeStorageService.refreshToken, result.token.refreshToken);
      expect(fakeStorageService.userData?['email'], 'ava.admin@nimbusdigital.test');
    });

    test('Login with invalid credentials throws AuthFailure', () async {
      expect(
        () => authUseCases.login(
          email: 'wrong@test.com',
          password: 'WrongPassword!',
        ),
        throwsA(isA<AuthFailure>()),
      );
    });

    test('Simulated token refresh produces updated token', () async {
      final loginRes = await authUseCases.login(
        email: 'marcus.member@nimbusdigital.test',
        password: 'Password123!',
      );

      final refreshed = await authUseCases.refreshToken(loginRes.token.refreshToken);
      expect(refreshed.accessToken, contains('refreshed'));
      expect(fakeStorageService.accessToken, refreshed.accessToken);
    });

    test('Logout clears stored tokens and user session', () async {
      await authUseCases.login(
        email: 'ava.admin@nimbusdigital.test',
        password: 'Password123!',
      );

      expect(fakeStorageService.accessToken, isNotNull);
      await authUseCases.logout();
      expect(fakeStorageService.accessToken, isNull);
      expect(fakeStorageService.userData, isNull);
    });
  });
}
