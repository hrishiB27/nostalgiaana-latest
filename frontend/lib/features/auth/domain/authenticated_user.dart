import '../../user/data/models/user_profile_model.dart';
import '../data/models/auth_response_model.dart';
import '../data/models/user_role.dart';

/// The logged-in user, as held in [AuthState] once OTP verification succeeds.
class AuthenticatedUser {
  const AuthenticatedUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.membershipStatus,
    this.email,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String? email;
  final UserRole role;
  final String membershipStatus;

  factory AuthenticatedUser.fromAuthResponse(AuthResponseModel response) {
    return AuthenticatedUser(
      id: response.userId,
      firstName: response.firstName,
      lastName: response.lastName,
      email: response.email,
      role: response.role,
      membershipStatus: response.membershipStatus,
    );
  }

  // Used by [AuthNotifier.refreshProfile] to re-sync role/membershipStatus
  // after a payment, without needing a fresh login.
  factory AuthenticatedUser.fromProfile(UserProfileModel profile) {
    return AuthenticatedUser(
      id: profile.id,
      firstName: profile.firstName,
      lastName: profile.lastName,
      email: profile.email,
      role: profile.role,
      membershipStatus: profile.membershipStatus,
    );
  }
}
