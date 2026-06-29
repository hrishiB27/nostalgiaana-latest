import '../data/models/content_detail_response_model.dart';

enum AdminContentStatus { initial, loading, loaded, error }

/// Shared state shape for [AdminShowsNotifier] and [AdminAudiosNotifier] —
/// the two notifiers stay separate (mirroring the backend's parallel
/// `/shows` and `/audios` resource groups), but the state they hold is
/// identical, so it isn't duplicated here.
class AdminContentState {
  const AdminContentState({
    this.status = AdminContentStatus.initial,
    this.items = const [],
    this.errorMessage,
    this.isSubmitting = false,
  });

  final AdminContentStatus status;
  final List<ContentDetailResponseModel> items;
  final String? errorMessage;
  final bool isSubmitting;

  AdminContentState copyWith({
    AdminContentStatus? status,
    List<ContentDetailResponseModel>? items,
    String? errorMessage,
    bool? isSubmitting,
  }) {
    return AdminContentState(
      status: status ?? this.status,
      items: items ?? this.items,
      // Not chained with `??`: a fresh action should clear any stale error
      // rather than carry it forward by default.
      errorMessage: errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}
