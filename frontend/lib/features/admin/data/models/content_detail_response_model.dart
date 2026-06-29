import '../../../content/data/models/content_type.dart';

/// Mirrors `ContentDetailResponse` on the backend, as returned by
/// `GET /api/admin/shows` and `GET /api/admin/audios`. Unlike the
/// listener-facing `ContentResponse`, this includes raw storage paths and
/// uploader attribution — admin-only detail.
class ContentDetailResponseModel {
  const ContentDetailResponseModel({
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
    required this.rawAudioPath,
    required this.rawVideoPath,
    required this.coverPath,
    required this.coverUrl,
    required this.hlsManifestPath,
    required this.uploadedByUserId,
    required this.uploadedByName,
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
  final String? rawAudioPath;
  final String? rawVideoPath;
  final String? coverPath;
  final String? coverUrl;
  final String? hlsManifestPath;
  final String? uploadedByUserId;
  final String? uploadedByName;

  factory ContentDetailResponseModel.fromJson(Map<String, dynamic> json) {
    return ContentDetailResponseModel(
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
      rawAudioPath: json['rawAudioPath'] as String?,
      rawVideoPath: json['rawVideoPath'] as String?,
      coverPath: json['coverPath'] as String?,
      coverUrl: json['coverUrl'] as String?,
      hlsManifestPath: json['hlsManifestPath'] as String?,
      uploadedByUserId: json['uploadedByUserId'] as String?,
      uploadedByName: json['uploadedByName'] as String?,
    );
  }
}
