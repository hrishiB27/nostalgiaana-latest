import 'user_role.dart';

/// Response body of `POST /api/auth/verify-otp` (`AuthResponse` on the backend).
class AuthResponseModel {
  const AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.membershipStatus,
    this.phone,
  });

  final String accessToken;
  final String refreshToken;
  final String userId;
  final String firstName;
  final String lastName;
  final String? phone;
  final UserRole role;
  final String membershipStatus;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      userId: json['userId'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String?,
      role: UserRole.fromJson(json['role'] as String),
      membershipStatus: json['membershipStatus'] as String,
    );
  }
}
