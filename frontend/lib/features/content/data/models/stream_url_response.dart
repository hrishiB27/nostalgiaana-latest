/// Response body of `GET /api/content/{id}/stream`
/// (`StreamUrlResponse` on the backend).
class StreamUrlResponse {
  const StreamUrlResponse({required this.url, required this.expiresInSeconds});

  final String url;
  final int expiresInSeconds;

  factory StreamUrlResponse.fromJson(Map<String, dynamic> json) {
    return StreamUrlResponse(
      url: json['url'] as String,
      expiresInSeconds: json['expiresInSeconds'] as int,
    );
  }
}
