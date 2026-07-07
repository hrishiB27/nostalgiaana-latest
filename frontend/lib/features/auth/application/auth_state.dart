import '../domain/authenticated_user.dart';

enum AuthStatus {
  initial,
  loading,
  otpRequired,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.otpIdentifier,
    this.otpExpiresInSeconds,
    this.errorMessage,
  });

  final AuthStatus status;
  final AuthenticatedUser? user;

  /// Identifier (phone number) the current OTP challenge was issued for.
  /// Set by [AuthNotifier.login] and consumed by [AuthNotifier.verifyOtp].
  final String? otpIdentifier;
  final int? otpExpiresInSeconds;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    AuthenticatedUser? user,
    String? otpIdentifier,
    int? otpExpiresInSeconds,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      otpIdentifier: otpIdentifier ?? this.otpIdentifier,
      otpExpiresInSeconds: otpExpiresInSeconds ?? this.otpExpiresInSeconds,
      // Not chained with `??` like the fields above: a fresh action should
      // clear any stale error rather than carry it forward by default.
      errorMessage: errorMessage,
    );
  }
}
