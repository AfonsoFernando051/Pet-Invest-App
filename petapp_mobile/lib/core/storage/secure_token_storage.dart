import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Single source of truth for the auth token, backed by the platform
/// keystore/keychain (Android EncryptedSharedPreferences / iOS Keychain)
/// instead of plaintext `SharedPreferences` — the token is a bearer
/// credential and must not sit in a plaintext prefs file on disk.
class SecureTokenStorage {
  SecureTokenStorage._();

  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  // Legacy plaintext key from before the migration to secure storage —
  // read once so upgrading users aren't silently logged out.
  static const _legacyPrefsKey = 'auth_token';

  static Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);

  static Future<String?> readToken() async {
    final token = await _storage.read(key: _tokenKey);
    if (token != null && token.isNotEmpty) return token;
    return _migrateLegacyToken();
  }

  static Future<void> clearToken() => _storage.delete(key: _tokenKey);

  static Future<String?> _migrateLegacyToken() async {
    final prefs = await SharedPreferences.getInstance();
    final legacyToken = prefs.getString(_legacyPrefsKey);
    if (legacyToken == null || legacyToken.isEmpty) return null;

    await _storage.write(key: _tokenKey, value: legacyToken);
    await prefs.remove(_legacyPrefsKey);
    return legacyToken;
  }
}
