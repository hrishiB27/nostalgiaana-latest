/// Mirrors `com.nostalgiaana.audio.user.UserRole` on the backend.
enum UserRole {
  listener,
  premium,
  admin;

  factory UserRole.fromJson(String value) {
    return UserRole.values.firstWhere(
      (role) => role.name.toUpperCase() == value.toUpperCase(),
      orElse: () => UserRole.listener,
    );
  }
}
