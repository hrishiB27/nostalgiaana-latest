import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/listener_content_api.dart';
import '../data/models/content_response_model.dart';

/// Family-keyed by the selected category id (`null` = "All"), so the
/// listener home screen can drive both shelves by simply watching with a
/// different argument when a filter chip is tapped — Riverpod handles the
/// refetch-and-cache per key.
final listenerShowsProvider =
    FutureProvider.family<List<ContentResponseModel>, String?>((ref, categoryId) {
  return ref.watch(listenerContentApiProvider).fetchShows(categoryId);
});

final listenerAudiosProvider =
    FutureProvider.family<List<ContentResponseModel>, String?>((ref, categoryId) {
  return ref.watch(listenerContentApiProvider).fetchAudios(categoryId);
});
