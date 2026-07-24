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
  bool _isLoggingOut = false;

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

  // Guards against a double-tap on the logout button re-entering this
  // method concurrently — two overlapping calls both stopping/disposing the
  // same audio/video players is exactly the race that used to trigger the
  // bug below (media_kit's Player.stop() throws on an already-disposed
  // player), so a second call while one is already in flight is a no-op.
  Future<void> logout() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;
    try {
      // Stop any active playback immediately — audioPlayerProvider/
      // videoPlayerProvider are app-wide singletons like dioProvider below,
      // so nothing else tears them down on logout. Explicitly awaiting
      // stop() (not just invalidating the provider) matters for the same
      // reason VideoPlayerScreen's own dispose/pop handling does — invalidate
      // alone races the async native stop, which is how a track has
      // previously survived teardown in this app. Each stop is wrapped as
      // best-effort: unlike just_audio, media_kit's Player.stop() throws an
      // AssertionError if the underlying native player was already disposed
      // (e.g. by a raced concurrent logout call) — previously that
      // exception was uncaught and aborted this whole method before the
      // tokens were ever cleared or `state` was set to unauthenticated,
      // which is exactly the "clicking log out does nothing" bug.
      await _bestEffort(() => ref.read(audioPlayerProvider.notifier).stop());
      await _bestEffort(() => ref.read(videoPlayerProvider.notifier).stop());
      await _bestEffort(() => ref.read(secureStorageProvider).clear());

      // dioProvider, the content providers (see _invalidateContentProviders),
      // and the audio/video players are all app-wide singletons that outlive
      // any one login session. Without invalidating them here, switching
      // accounts in the same running app can leave a stale Dio client or a
      // leftover player instance around from the prior account — invisible
      // after a fresh app start (new providers every time) but reproducible
      // when logging out and back in without restarting.
      ref.invalidate(dioProvider);
      ref.invalidate(audioPlayerProvider);
      ref.invalidate(videoPlayerProvider);
      _invalidateContentProviders();
    } finally {
      // Always settles here, even if something above threw unexpectedly —
      // logging out must never leave the app stuck showing "authenticated"
      // with no visible feedback.
      state = const AuthState(status: AuthStatus.unauthenticated);
      _isLoggingOut = false;
    }
  }

  Future<void> _bestEffort(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      // See logout()'s comment above — cleanup failures must not block the
      // rest of logout from completing.
    }
  }

  /// Invalidates every content-fetch provider that isn't tied to a specific
  /// screen's lifecycle (plain NotifierProvider/FutureProvider(.family), no
  /// autoDispose) — without this, a stuck error from a transient post-login
  /// race (or any other cause) would persist indefinitely, even across a
  /// logout/login cycle in the same running app, since nothing else ever
  /// invalidates these. Called on login()/signup() too, not just logout() —
  /// previously the admin providers were only cleared on logout, so a stale
  /// cached error from an earlier attempt in the same session could resurface
  /// immediately on an otherwise-successful fresh login.
  void _invalidateContentProviders() {
    ref.invalidate(listenerShowsProvider);
    ref.invalidate(listenerAudiosProvider);
    ref.invalidate(categoriesProvider);
    ref.invalidate(adminShowsProvider);
    ref.invalidate(adminAudiosProvider);
    ref.invalidate(adminUsersProvider);
  }

  /// Called once from [SplashScreen] on a cold start. A token surviving in
  /// secure storage doesn't mean the session is still valid server-side
  /// (expired, or the account was suspended/denied since last login) — so
  /// this re-validates against `/api/user/me` rather than trusting the
  /// stored token alone, the same check [refreshProfile] does post-payment,
  /// just run earlier in the app lifecycle.
  Future<void> restoreSession() async {
    final storage = ref.read(secureStorageProvider);
    final token = await storage.getAccessToken();
    if (token == null) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final profile = await ref.read(userApiProvider).me();
      state = AuthState(
        status: AuthStatus.authenticated,
        user: AuthenticatedUser.fromProfile(profile),
      );
    } catch (_) {
      await storage.clear();
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
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
