import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_error.dart';
import '../data/comment_api.dart';
import 'comments_state.dart';

/// Comments are scoped per content id, and `ContentDetailScreen` is pushed
/// fresh per item — a singleton `Notifier` (like every other one in this
/// app) would leak the previous item's comments into the next screen
/// instance, so this is `.family`-keyed by content id and `.autoDispose`s
/// once the detail screen is popped.
class CommentsNotifier extends Notifier<CommentsState> {
  CommentsNotifier(this.contentId);

  final String contentId;

  @override
  CommentsState build() => const CommentsState();

  Future<void> load() async {
    state = state.copyWith(status: CommentsStatus.loading);
    try {
      final fetched = await ref.read(commentApiProvider).fetchComments(contentId);
      // Merge rather than blind-replace: if post() appended a comment locally
      // while this fetch was in flight (e.g. the user posts before the
      // initial load resolves), a stale GET response landing afterward must
      // not silently wipe the user's own just-submitted comment back out.
      final fetchedIds = fetched.map((c) => c.id).toSet();
      final localOnly = state.items.where((c) => !fetchedIds.contains(c.id));
      state = state.copyWith(status: CommentsStatus.loaded, items: [...fetched, ...localOnly]);
    } catch (error) {
      state = state.copyWith(status: CommentsStatus.error, errorMessage: messageFor(error));
    }
  }

  // Appends the server-returned comment on success rather than refetching —
  // there's no real id/createdAt to show before the response lands, so no
  // speculative row is inserted ahead of it either.
  Future<void> post(String text) async {
    state = state.copyWith(isSubmitting: true, submitError: null);
    try {
      final created = await ref.read(commentApiProvider).postComment(contentId, text);
      state = state.copyWith(isSubmitting: false, items: [...state.items, created]);
    } catch (error) {
      state = state.copyWith(isSubmitting: false, submitError: messageFor(error));
    }
  }
}

final commentsProvider =
    NotifierProvider.autoDispose.family<CommentsNotifier, CommentsState, String>(
  CommentsNotifier.new,
);
