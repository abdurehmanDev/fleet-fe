// ─── Secure Storage Service ───────────────────────────────────────────────────
// Wrapper around flutter_secure_storage for token/user data management
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rangrej_fleet/core/constants/app_constants.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  const SecureStorageService(this._storage);

  // ── Access Token ─────────────────────────────────────────────────────────
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: AppConstants.accessTokenKey, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: AppConstants.accessTokenKey);
  }

  // ── Refresh Token ─────────────────────────────────────────────────────────
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: AppConstants.refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: AppConstants.refreshTokenKey);
  }

  // ── User Data ─────────────────────────────────────────────────────────────
  Future<void> saveUserData(String userData) async {
    await _storage.write(key: AppConstants.userDataKey, value: userData);
  }

  Future<String?> getUserData() async {
    return await _storage.read(key: AppConstants.userDataKey);
  }

  // ── Clear All ─────────────────────────────────────────────────────────────
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // ── Auth State ────────────────────────────────────────────────────────────
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
