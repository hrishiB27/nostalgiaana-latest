/// Response body of `POST /api/auth/login` (`OtpChallengeResponse` on the backend).
class OtpChallengeResponse {
  const OtpChallengeResponse({
    required this.message,
    required this.preAuthToken,
    required this.identifier,
    required this.expiresInSeconds,
  });

  final String message;
  final String preAuthToken;
  final String identifier;
  final int expiresInSeconds;

  factory OtpChallengeResponse.fromJson(Map<String, dynamic> json) {
    return OtpChallengeResponse(
      message: json['message'] as String,
      preAuthToken: json['preAuthToken'] as String,
      identifier: json['identifier'] as String,
      expiresInSeconds: json['expiresInSeconds'] as int,
    );
  }
}
