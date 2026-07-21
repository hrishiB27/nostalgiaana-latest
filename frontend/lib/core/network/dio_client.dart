import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';

/// The single Dio instance the rest of the app should depend on. Every
/// request is transparently stamped with the stored JWT, so feature code
/// never has to read tokens or set the Authorization header itself.
final dioProvider = Provider<Dio>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      // The production backend is a Render free-tier service that spins
      // down when idle — the first request after any idle period can take
      // 30-90s to wake it (see root CLAUDE.md's deployment-architecture
      // notes). A short timeout would fail that request before the server
      // ever finishes waking up, so both timeouts are set to the
      // documented worst case rather than a typical warm-request latency.
      connectTimeout: const Duration(seconds: 90),
      receiveTimeout: const Duration(seconds: 90),
      headers: const {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await secureStorage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      // Guards against a narrow race right after login: the dashboard's
      // first content requests can fire in the same frame the JWT is
      // persisted, and secure-storage's write isn't always guaranteed
      // visible to an immediate read-back yet on every platform. A single
      // retry with a freshly re-read token resolves that without masking a
      // genuinely expired/invalid session — a repeat 401 just passes
      // through to the caller as normal. Safe for every HTTP method: a 401
      // here comes from JwtAuthFilter/JsonAuthenticationEntryPoint at the
      // Spring Security filter level, before the request ever reaches a
      // controller, so no business logic (and no mutation) ran yet.
      onError: (error, handler) async {
        final alreadyRetried = error.requestOptions.extra['retriedAfter401'] == true;
        if (error.response?.statusCode == 401 && !alreadyRetried) {
          // A brief pause before re-reading the token widens the window
          // for the secure-storage write to become visible — an
          // immediate re-read can still lose the same race on a slower
          // platform.
          await Future.delayed(const Duration(milliseconds: 300));
          final token = await secureStorage.getAccessToken();
          if (token != null) {
            try {
              final retryOptions = error.requestOptions
                ..extra['retriedAfter401'] = true
                ..headers['Authorization'] = 'Bearer $token';
              final response = await dio.fetch(retryOptions);
              handler.resolve(response);
              return;
            } catch (_) {
              // Fall through — surface the original error below.
            }
          }
        }
        handler.next(error);
      },
    ),
  );

  return dio;
});
