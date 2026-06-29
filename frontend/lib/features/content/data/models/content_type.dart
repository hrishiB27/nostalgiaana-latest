/// Mirrors `com.nostalgiaana.audio.content.ContentType` on the backend.
/// Shared between the admin upload/management feature and the (future)
/// listener-facing content feature, exactly like the backend's `content`
/// package is shared with `admin`.
enum ContentType {
  show,
  audio;

  factory ContentType.fromJson(String value) {
    return ContentType.values.firstWhere(
      (type) => type.name.toUpperCase() == value.toUpperCase(),
      orElse: () => ContentType.audio,
    );
  }

  String toJson() => name.toUpperCase();
}
