import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_error.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../admin/application/admin_audios_notifier.dart';
import '../../admin/application/admin_shows_notifier.dart';
import '../../admin/application/admin_users_notifier.dart';
import '../../category/application/category_providers.dart';
import '../../content/application/audio_player_notifier.dart';
import '../../content/application/listener_content_providers.dart';
import '../../content/application/video_player_notifier.dart';
import '../../user/data/user_api.dart';
import '../data/auth_api.dart';
import '../data/models/signup_request.dart';
import '../domain/authenticated_user.dart';
import 'auth_state.dart';

/// Drives the login -> authenticated flow described in `audio/CLAUDE.md`'s
/// Auth section. JWTs are persisted to secure storage as soon as the
/// password check succeeds; nothing else needs to touch them directly
/// because [dioProvider] reads them back on every request.
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  // Signup has no OTP step on the backend — it returns real tokens immediately.
  Future<void> signup(SignupRequest request) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final response = await ref.read(authApiProvider).signup(request);
      await ref.read(secureStorageProvider).saveTokens(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken,
          );
      _invalidateContentProviders();
      state = AuthState(
        status: AuthStatus.authenticated,
        user: AuthenticatedUser.fromAuthResponse(response),
      );
    } catch (error) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: messageFor(error));
    }
  }

  Future<void> login({required String identifier, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final response = await ref.read(authApiProvider).login(
            identifier: identifier,
            password: password,
          );
      await ref.read(secureStorageProvider).saveTokens(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken,
          );
      _invalidateContentProviders();
      state = AuthState(
        status: AuthStatus.authenticated,
        user: AuthenticatedUser.fromAuthResponse(response),
      );
    } catch (error) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: messageFor(error));
    }
  }

  Future<void> logout() async {
    // Stop any active playback immediately — audioPlayerProvider/
    // videoPlayerProvider are app-wide singletons like dioProvider below,
    // so nothing else tears them down on logout. Explicitly awaiting
    // stop() (not just invalidating the provider) matters for the same
    // reason VideoPlayerScreen's own dispose/pop handling does — invalidate
    // alone races the async native stop, which is how a track has
    // previously survived teardown in this app.
    await ref.read(audioPlayerProvider.notifier).stop();
    await ref.read(videoPlayerProvider.notifier).stop();

    await ref.read(secureStorageProvider).clear();
    // dioProvider (and every *ApiProvider that watches it), the admin
    // content providers, and the audio/video players are all app-wide
    // singletons that outlive any one login session. Without invalidating
    // them here, switching accounts in the same running app can leave a
    // stale Dio client, cached admin shows/audios/users state (e.g. a
    // previous 403), or a leftover player instance around from the prior
    // account — invisible after a fresh app start (new providers every
    // time) but reproducible when logging out and back in without
    // restarting.
    ref.invalidate(dioProvider);
    ref.invalidate(adminShowsProvider);
    ref.invalidate(adminAudiosProvider);
    ref.invalidate(adminUsersProvider);
    ref.invalidate(audioPlayerProvider);
    ref.invalidate(videoPlayerProvider);
    _invalidateContentProviders();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Invalidates every content-fetch provider that isn't tied to a specific
  /// screen's lifecycle (plain FutureProvider(.family), no autoDispose) —
  /// without this, a stuck error from a transient post-login race (or any
  /// other cause) would persist indefinitely, even across a logout/login
  /// cycle in the same running app, since nothing else ever invalidates
  /// these.
  void _invalidateContentProviders() {
    ref.invalidate(listenerShowsProvider);
    ref.invalidate(listenerAudiosProvider);
    ref.invalidate(categoriesProvider);
  }

  /// Re-syncs `role`/`membershipStatus` from `GET /api/user/me` without a
  /// fresh login — needed after a payment, since the Razorpay webhook that
  /// flips a user to PREMIUM runs server-to-server and the JWT/AuthResponse
  /// the client already holds has no way to reflect that on its own.
  Future<void> refreshProfile() async {
    if (state.user == null) return;
    try {
      final profile = await ref.read(userApiProvider).me();
      state = state.copyWith(user: AuthenticatedUser.fromProfile(profile));
    } catch (_) {
      // Best-effort: leave the existing user state alone if this fails:
      // the caller (PaymentNotifier) decides how to react, e.g. by retrying.
    }
  }
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
