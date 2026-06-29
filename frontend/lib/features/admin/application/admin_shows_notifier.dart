import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_error.dart';
import '../data/admin_content_api.dart';
import '../data/models/content_upload_request.dart';
import 'admin_content_state.dart';

/// Drives the Manage Shows screen: list load, upload (then a full refresh,
/// since `POST /shows` only returns a `ContentResponse`, not the
/// `ContentDetailResponse` the list itself needs), and delete (which
/// removes the row locally rather than refetching).
class AdminShowsNotifier extends Notifier<AdminContentState> {
  @override
  AdminContentState build() => const AdminContentState();

  Future<void> load() async {
    state = state.copyWith(status: AdminContentStatus.loading);
    try {
      final items = await ref.read(adminContentApiProvider).listShows();
      state = state.copyWith(status: AdminContentStatus.loaded, items: items);
    } catch (error) {
      state = state.copyWith(status: AdminContentStatus.error, errorMessage: messageFor(error));
    }
  }

  Future<void> upload(ContentUploadRequest request, PlatformFile video, PlatformFile? thumbnail) async {
    state = state.copyWith(isSubmitting: true);
    try {
      await ref.read(adminContentApiProvider).uploadShow(request, video, thumbnail);
      await load();
      state = state.copyWith(isSubmitting: false);
    } catch (error) {
      state = state.copyWith(isSubmitting: false, errorMessage: messageFor(error));
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    try {
      await ref.read(adminContentApiProvider).deleteShow(id);
      state = state.copyWith(items: state.items.where((item) => item.id != id).toList());
    } catch (error) {
      state = state.copyWith(errorMessage: messageFor(error));
      rethrow;
    }
  }
}

final adminShowsProvider = NotifierProvider<AdminShowsNotifier, AdminContentState>(
  AdminShowsNotifier.new,
);
