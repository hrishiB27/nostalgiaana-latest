import '../../../auth/data/models/user_role.dart';

/// Mirrors `AdminUserResponse` on the backend, as returned by
/// `GET /api/admin/users` (ADMIN-role accounts are excluded server-side).
class AdminUserResponseModel {
  const AdminUserResponseModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.country,
    required this.city,
    required this.role,
    required this.membershipTier,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  // Nullable: some accounts (e.g. created without the full signup flow)
  // have neither name set.
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? country;
  final String? city;
  final UserRole role;
  final String membershipTier;
  final bool isActive;
  final DateTime createdAt;

  String get displayName {
    final name = [firstName, lastName].where((part) => part != null && part.isNotEmpty).join(' ');
    return name.isNotEmpty ? name : 'Unnamed user';
  }

  factory AdminUserResponseModel.fromJson(Map<String, dynamic> json) {
    return AdminUserResponseModel(
      id: json['id'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phone: json['phone'] as String?,
      country: json['country'] as String?,
      city: json['city'] as String?,
      role: UserRole.fromJson(json['role'] as String),
      membershipTier: json['membershipTier'] as String,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  AdminUserResponseModel copyWith({bool? isActive}) {
    return AdminUserResponseModel(
      id: id,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      country: country,
      city: city,
      role: role,
      membershipTier: membershipTier,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }
}
