import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class StorageService {
  Future<void> setAccessToken(String token);
  Future<String?> getAccessToken();
  Future<void> setRefreshToken(String token);
  Future<String?> getRefreshToken();
  Future<void> setTokenExpiry(DateTime expiry);
  Future<DateTime?> getTokenExpiry();
  Future<void> clearAuthData();

  Future<void> saveCurrentUserData(Map<String, dynamic> data);
  Map<String, dynamic>? getCurrentUserData();

  Future<void> setDarkMode(bool isDark);
  bool getDarkMode();

  Future<void> saveCachedData(String key, dynamic data);
  dynamic getCachedData(String key);
  Future<void> clearAll();
}

class StorageServiceImpl implements StorageService {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  static const _kAccessToken = 'tf_access_token';
  static const _kRefreshToken = 'tf_refresh_token';
  static const _kTokenExpiry = 'tf_token_expiry';
  static const _kCurrentUserData = 'tf_current_user_data';
  static const _kDarkMode = 'tf_dark_mode';

  StorageServiceImpl({
    required SharedPreferences prefs,
    required FlutterSecureStorage secureStorage,
  })  : _prefs = prefs,
        _secureStorage = secureStorage;

  @override
  Future<void> setAccessToken(String token) async {
    await _secureStorage.write(key: _kAccessToken, value: token);
  }

  @override
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _kAccessToken);
  }

  @override
  Future<void> setRefreshToken(String token) async {
    await _secureStorage.write(key: _kRefreshToken, value: token);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _kRefreshToken);
  }

  @override
  Future<void> setTokenExpiry(DateTime expiry) async {
    await _prefs.setString(_kTokenExpiry, expiry.toIso8601String());
  }

  @override
  Future<DateTime?> getTokenExpiry() async {
    final str = _prefs.getString(_kTokenExpiry);
    return str != null ? DateTime.tryParse(str) : null;
  }

  @override
  Future<void> clearAuthData() async {
    await _secureStorage.delete(key: _kAccessToken);
    await _secureStorage.delete(key: _kRefreshToken);
    await _prefs.remove(_kTokenExpiry);
    await _prefs.remove(_kCurrentUserData);
  }

  @override
  Future<void> saveCurrentUserData(Map<String, dynamic> data) async {
    await _prefs.setString(_kCurrentUserData, jsonEncode(data));
  }

  @override
  Map<String, dynamic>? getCurrentUserData() {
    final str = _prefs.getString(_kCurrentUserData);
    if (str == null) return null;
    try {
      return jsonDecode(str) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> setDarkMode(bool isDark) async {
    await _prefs.setBool(_kDarkMode, isDark);
  }

  @override
  bool getDarkMode() {
    return _prefs.getBool(_kDarkMode) ?? false;
  }

  @override
  Future<void> saveCachedData(String key, dynamic data) async {
    await _prefs.setString('cache_$key', jsonEncode(data));
  }

  @override
  dynamic getCachedData(String key) {
    final str = _prefs.getString('cache_$key');
    if (str == null) return null;
    try {
      return jsonDecode(str);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await _prefs.clear();
  }
}
