import '../domain/authenticated_user.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  final AuthStatus status;
  final AuthenticatedUser? user;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    AuthenticatedUser? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      // Not chained with `??` like the fields above: a fresh action should
      // clear any stale error rather than carry it forward by default.
      errorMessage: errorMessage,
    );
  }
}
