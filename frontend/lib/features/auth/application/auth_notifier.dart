import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/secure_storage_service.dart';
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
      state = state.copyWith(status: AuthStatus.error, errorMessage: _messageFor(error));
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
      state = state.copyWith(status: AuthStatus.error, errorMessage: _messageFor(error));
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
      state = state.copyWith(status: AuthStatus.error, errorMessage: _messageFor(error));
    }
  }

  Future<void> logout() async {
    await ref.read(secureStorageProvider).clear();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Drops back to phase 1 (e.g. user backs out of the OTP screen, or
  /// switches between the Login and Sign Up layouts) without touching
  /// stored tokens.
  void reset() {
    state = const AuthState();
  }

  // The backend's GlobalExceptionHandler wraps every business-rule failure
  // (bad password, wrong OTP, etc.) as {"error": "<message>", ...} with a 400.
  String _messageFor(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['error'] is String) {
        return data['error'] as String;
      }
    }
    return 'Something went wrong. Please try again.';
  }
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
