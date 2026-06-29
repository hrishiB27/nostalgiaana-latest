import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import 'models/content_response_model.dart';
import 'models/stream_url_response.dart';

/// Thin wrapper over the listener-facing `/api/content/**` endpoints.
class ListenerContentApi {
  const ListenerContentApi(this._dio);

  final Dio _dio;

  Future<List<ContentResponseModel>> fetchShows(String? categoryId) {
    return _fetch('/content/shows', categoryId);
  }

  Future<List<ContentResponseModel>> fetchAudios(String? categoryId) {
    return _fetch('/content/audios', categoryId);
  }

  Future<StreamUrlResponse> getStreamUrl(String contentId) async {
    final response = await _dio.get<Map<String, dynamic>>('/content/$contentId/stream');
    return StreamUrlResponse.fromJson(response.data!);
  }

  Future<List<ContentResponseModel>> _fetch(String path, String? categoryId) async {
    final response = await _dio.get<List<dynamic>>(
      path,
      queryParameters: categoryId != null ? {'categoryId': categoryId} : null,
    );
    return response.data!
        .map((json) => ContentResponseModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

final listenerContentApiProvider = Provider<ListenerContentApi>((ref) {
  return ListenerContentApi(ref.watch(dioProvider));
});
