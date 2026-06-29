import '../../../auth/data/models/user_role.dart';

/// Response body of `GET /api/user/me` (`UserProfileResponse` on the
/// backend) — the only endpoint that lets the app re-check the current
/// user's role/membershipStatus without forcing a logout/login, which
/// matters right after a payment: the webhook that flips a user to
/// PREMIUM runs server-to-server, so this is how the client finds out.
class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.membershipStatus,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String? email;
  final UserRole role;
  final String membershipStatus;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String?,
      role: UserRole.fromJson(json['role'] as String),
      membershipStatus: json['membershipStatus'] as String,
    );
  }
}
