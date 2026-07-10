import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_error.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../admin/application/admin_audios_notifier.dart';
import '../../admin/application/admin_shows_notifier.dart';
import '../../admin/application/admin_users_notifier.dart';
import '../../user/data/user_api.dart';
import '../data/auth_api.dart';
import '../data/models/signup_request.dart';
import '../domain/authenticated_user.dart';
import 'auth_state.dart';

/// Drives the login -> OTP -> authenticated flow described in
/// `audio/CLAUDE.md`'s Auth section. JWTs are persisted to secure storage
/// as soon as OTP verification succeeds; nothing else needs to touch them
/// directly because [dioProvider] reads them back on every request.
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
      final challenge = await ref.read(authApiProvider).login(
            identifier: identifier,
            password: password,
          );
      state = AuthState(
        status: AuthStatus.otpRequired,
        otpIdentifier: challenge.identifier,
        otpExpiresInSeconds: challenge.expiresInSeconds,
      );
    } catch (error) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: messageFor(error));
    }
  }

  Future<void> verifyOtp(String otp) async {
    final identifier = state.otpIdentifier;
    if (identifier == null) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Start the login flow again before entering an OTP.',
      );
      return;
    }

    state = state.copyWith(status: AuthStatus.loading);
    try {
      final response = await ref.read(authApiProvider).verifyOtp(
            identifier: identifier,
            otp: otp,
          );
      await ref.read(secureStorageProvider).saveTokens(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken,
          );
      state = AuthState(
        status: AuthStatus.authenticated,
        user: AuthenticatedUser.fromAuthResponse(response),
      );
    } catch (error) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: messageFor(error));
    }
  }

  Future<void> logout() async {
    await ref.read(secureStorageProvider).clear();
    // dioProvider (and every *ApiProvider that watches it) and the admin
    // content providers are app-wide singletons that outlive any one login
    // session. Without invalidating them here, switching accounts in the
    // same running app can leave a stale Dio client or cached admin
    // shows/audios/users state (e.g. a previous 403) around from the prior
    // account — invisible after a fresh app start (new providers every
    // time) but reproducible when logging out and back in without
    // restarting.
    ref.invalidate(dioProvider);
    ref.invalidate(adminShowsProvider);
    ref.invalidate(adminAudiosProvider);
    ref.invalidate(adminUsersProvider);
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Drops back to phase 1 (e.g. user backs out of the OTP screen, or
  /// switches between the Login and Sign Up layouts) without touching
  /// stored tokens.
  void reset() {
    state = const AuthState();
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
