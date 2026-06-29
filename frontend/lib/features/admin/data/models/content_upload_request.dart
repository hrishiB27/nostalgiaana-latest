/// Request body of the `data` part on `POST/PUT /api/admin/shows|audios`
/// (`ContentUploadRequest` on the backend).
class ContentUploadRequest {
  const ContentUploadRequest({
    required this.title,
    this.description,
    this.categoryId,
    this.speaker,
    this.isPremium = false,
  });

  final String title;
  final String? description;
  final String? categoryId;
  final String? speaker;
  final bool isPremium;

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'categoryId': categoryId,
        'speaker': speaker,
        'isPremium': isPremium,
      };
}
