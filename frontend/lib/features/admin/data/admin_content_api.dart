import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';

import '../../../core/network/dio_client.dart';
import 'models/content_detail_response_model.dart';
import 'models/content_upload_request.dart';

/// Thin wrapper over the ADMIN-only `/api/admin/shows` and
/// `/api/admin/audios` endpoints. Kept as one class with parallel method
/// pairs (not a generic "content" method) because the backend itself keeps
/// these as two parallel resource groups with different multipart field
/// names (`video` vs `audio`), not a single type-parameterized endpoint.
class AdminContentApi {
  const AdminContentApi(this._dio);

  final Dio _dio;

  Future<List<ContentDetailResponseModel>> listShows() => _list('/admin/shows');

  Future<List<ContentDetailResponseModel>> listAudios() => _list('/admin/audios');

  Future<void> uploadShow(ContentUploadRequest request, PlatformFile video, PlatformFile? thumbnail) {
    return _upload('/admin/shows', request, mediaFieldName: 'video', media: video, thumbnail: thumbnail);
  }

  Future<void> uploadAudio(ContentUploadRequest request, PlatformFile audio, PlatformFile? thumbnail) {
    return _upload('/admin/audios', request, mediaFieldName: 'audio', media: audio, thumbnail: thumbnail);
  }

  Future<void> deleteShow(String id) => _dio.delete('/admin/shows/$id');

  Future<void> deleteAudio(String id) => _dio.delete('/admin/audios/$id');

  Future<List<ContentDetailResponseModel>> _list(String path) async {
    final response = await _dio.get<List<dynamic>>(path);
    return response.data!
        .map((json) => ContentDetailResponseModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> _upload(
    String path,
    ContentUploadRequest request, {
    required String mediaFieldName,
    required PlatformFile media,
    PlatformFile? thumbnail,
  }) async {
    final formData = FormData.fromMap({
      'data': MultipartFile.fromString(
        jsonEncode(request.toJson()),
        contentType: MediaType('application', 'json'),
      ),
      mediaFieldName: await _multipartFromPlatformFile(media),
      if (thumbnail != null) 'thumbnail': await _multipartFromPlatformFile(thumbnail),
    });
    await _dio.post<void>(path, data: formData);
  }

  // file_picker only populates `path` on mobile/desktop and `bytes` on web
  // (no filesystem access there) — the caller decides which to request via
  // `withData`, so both must be handled here.
  Future<MultipartFile> _multipartFromPlatformFile(PlatformFile file) async {
    if (file.path != null) {
      return MultipartFile.fromFile(file.path!, filename: file.name);
    }
    return MultipartFile.fromBytes(file.bytes!, filename: file.name);
  }
}

final adminContentApiProvider = Provider<AdminContentApi>((ref) {
  return AdminContentApi(ref.watch(dioProvider));
});
