/// Request body of `POST /api/auth/signup` (`SignupRequest` on the backend).
/// `email` and `password` are required by the Sign Up form; the backend
/// itself also accepts `phone`/`country`/`city`, which the form doesn't
/// collect yet.
class SignupRequest {
  const SignupRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String password;

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
      };
}
