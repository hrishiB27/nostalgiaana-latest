import '../data/models/comment_model.dart';

enum CommentsStatus { initial, loading, loaded, error }

/// Holds both the fetched comment list and the in-flight state of posting
/// a new one — a single content id's worth of comment activity.
class CommentsState {
  const CommentsState({
    this.status = CommentsStatus.initial,
    this.items = const [],
    this.errorMessage,
    this.isSubmitting = false,
    this.submitError,
  });

  final CommentsStatus status;
  final List<CommentModel> items;
  final String? errorMessage;
  final bool isSubmitting;
  final String? submitError;

  CommentsState copyWith({
    CommentsStatus? status,
    List<CommentModel>? items,
    String? errorMessage,
    bool? isSubmitting,
    String? submitError,
  }) {
    return CommentsState(
      status: status ?? this.status,
      items: items ?? this.items,
      // Not chained with `??`: a fresh action should clear any stale error
      // rather than carry it forward by default.
      errorMessage: errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: submitError,
    );
  }
}
