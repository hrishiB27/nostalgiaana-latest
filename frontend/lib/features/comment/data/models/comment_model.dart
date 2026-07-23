/// A single comment on a piece of content, from `GET/POST
/// /api/content/{id}/comments` (mirrors the `/api/content/{id}/stream`
/// nesting).
class CommentModel {
  const CommentModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String? authorId;
  final String authorName;
  final String text;
  final DateTime createdAt;

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      authorId: json['authorId'] as String?,
      authorName: json['authorName'] as String,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
