import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import 'models/comment_model.dart';

/// Thin wrapper over `/api/content/{id}/comments` — not live on the backend
/// yet, but shaped to match the existing `/content/{id}/stream` nesting so
/// wiring it up later needs no client-side changes.
class CommentApi {
  const CommentApi(this._dio);

  final Dio _dio;

  Future<List<CommentModel>> fetchComments(String contentId) async {
    final response = await _dio.get<List<dynamic>>('/content/$contentId/comments');
    return response.data!
        .map((json) => CommentModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // The author is derived server-side from the JWT (matching this backend's
  // existing @AuthenticationPrincipal pattern), so no author id is sent here.
  Future<CommentModel> postComment(String contentId, String text) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/content/$contentId/comments',
      data: {'text': text},
    );
    return CommentModel.fromJson(response.data!);
  }
}

final commentApiProvider = Provider<CommentApi>((ref) {
  return CommentApi(ref.watch(dioProvider));
});
