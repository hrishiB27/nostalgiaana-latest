/// Request body of `POST /api/auth/signup` (`SignupRequest` on the backend).
/// All fields here are required by the Sign Up form.
class SignupRequest {
  const SignupRequest({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.country,
    required this.city,
    required this.password,
  });

  final String firstName;
  final String lastName;
  final String phone;
  final String country;
  final String city;
  final String password;

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'country': country,
        'city': city,
        'password': password,
      };
}
