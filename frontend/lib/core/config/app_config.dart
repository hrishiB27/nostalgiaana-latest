import 'package:flutter/foundation.dart';

/// Backend base URL per platform for local development.
///
/// The Android emulator can't reach the host's `localhost` directly — it
/// must use the special alias `10.0.2.2`. iOS simulators, web, and desktop
/// share the host's network stack, so `localhost` works for them.
/// A physical device needs the host machine's LAN IP instead; this isn't
/// handled here and must be set manually when testing on hardware.
class AppConfig {
  const AppConfig._();

  static String get apiBaseUrl {
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
