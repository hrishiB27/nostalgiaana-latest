import 'content_type.dart';

/// Mirrors `ContentResponse` on the backend, as returned by
/// `GET /api/content/shows` and `GET /api/content/audios`. Unlike the
/// admin-only `ContentDetailResponse`, this has no raw storage paths or
/// uploader attribution — just what a listener's UI needs.
class ContentResponseModel {
  const ContentResponseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.contentType,
    required this.categoryId,
    required this.categoryName,
    required this.speaker,
    required this.durationSeconds,
    required this.isPremium,
    required this.playCount,
    required this.uploadDate,
    required this.coverUrl,
  });

  final String id;
  final String title;
  final String? description;
  final ContentType contentType;
  final String? categoryId;
  final String? categoryName;
  final String? speaker;
  final int? durationSeconds;
  final bool isPremium;
  final int playCount;
  final DateTime uploadDate;
  final String? coverUrl;

  factory ContentResponseModel.fromJson(Map<String, dynamic> json) {
    return ContentResponseModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      contentType: ContentType.fromJson(json['contentType'] as String),
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String?,
      speaker: json['speaker'] as String?,
      durationSeconds: json['durationSeconds'] as int?,
      isPremium: json['isPremium'] as bool? ?? false,
      playCount: json['playCount'] as int? ?? 0,
      uploadDate: DateTime.parse(json['uploadDate'] as String),
      coverUrl: json['coverUrl'] as String?,
    );
  }
}
