import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wraps [FlutterSecureStorage] for the two JWTs the backend issues on
/// `/api/auth/login`. Nothing else in the app should touch token storage
/// directly.
class SecureStorageService {
  SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  static const _accessTokenKey = 'nostalgiaana.accessToken';
  static const _refreshTokenKey = 'nostalgiaana.refreshToken';

  // Written synchronously by saveTokens()/clear() so dio_client.dart's
  // interceptor can read the current token back out without an async
  // platform round-trip — a just-completed secure-storage write isn't
  // guaranteed to be immediately visible to an immediate subsequent read on
  // every platform, which used to surface as an intermittent "Authentication
  // required" on the very first request right after login. This cache is
  // the source of truth whenever this process has ever called saveTokens();
  // it's only empty on a cold app start, where getAccessToken() falls back
  // to the real platform read (used by restoreSession()).
  String? _cachedAccessToken;

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _cachedAccessToken = accessToken;
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
  }

  Future<String?> getAccessToken() async {
    if (_cachedAccessToken != null) return _cachedAccessToken;
    return _cachedAccessToken = await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> clear() async {
    _cachedAccessToken = null;
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
    ]);
  }
}

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService(const FlutterSecureStorage());
});
