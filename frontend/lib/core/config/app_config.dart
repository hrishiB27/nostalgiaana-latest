import 'package:flutter/foundation.dart';

/// Backend base URL.
///
/// Priority:
/// 1. `--dart-define=API_BASE_URL=...` — explicit override, e.g. pointing
///    at the deployed production backend:
///    `flutter run --dart-define=API_BASE_URL=https://api.<domain>/api`
///    (same flag for `flutter build apk`/`build ios`/`build windows`).
///    The app never constructs a MinIO URL itself — cover/audio/video
///    URLs come back as complete presigned URLs in API response bodies
///    and are used as-is — so this single override is sufficient; there's
///    no separate storage-endpoint value to configure client-side.
/// 2. Release builds (`kReleaseMode`), when no override is supplied —
///    resolve straight to the deployed production backend, so a release
///    build never accidentally ships pointed at a dev machine's localhost.
/// 3. Per-platform local-dev default, for debug/profile builds — the
///    Android emulator can't reach the host's `localhost` directly and
///    must use the special alias `10.0.2.2`; iOS simulators, web, and
///    desktop share the host's network stack, so `localhost` works for
///    them.
class AppConfig {
  const AppConfig._();

  static const String _apiBaseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
  );

  static const String _productionApiBaseUrl =
      'https://nostalgiaana-audio.onrender.com/api';

  static String get apiBaseUrl {
    if (_apiBaseUrlOverride.isNotEmpty) {
      return _apiBaseUrlOverride;
    }
    if (kReleaseMode) {
      return _productionApiBaseUrl;
    }
    if (kIsWeb) {
      return 'http://localhost:8080/api';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8080/api';
      default:
        return 'http://localhost:8080/api';
    }
  }
}
