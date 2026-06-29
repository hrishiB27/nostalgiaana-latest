import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import 'models/user_profile_model.dart';

/// Thin wrapper over `GET /api/user/me`.
class UserApi {
  const UserApi(this._dio);

  final Dio _dio;

  Future<UserProfileModel> me() async {
    final response = await _dio.get<Map<String, dynamic>>('/user/me');
    return UserProfileModel.fromJson(response.data!);
  }
}

final userApiProvider = Provider<UserApi>((ref) {
  return UserApi(ref.watch(dioProvider));
});
