import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import 'models/admin_user_response_model.dart';

/// Thin wrapper over the ADMIN-only `/api/admin/users` endpoints.
class AdminUserApi {
  const AdminUserApi(this._dio);

  final Dio _dio;

  Future<List<AdminUserResponseModel>> listUsers() async {
    final response = await _dio.get<List<dynamic>>('/admin/users');
    return response.data!
        .map((json) => AdminUserResponseModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // Soft-ban: the backend sets isActive=false rather than deleting the row.
  Future<void> banUser(String id) async {
    await _dio.delete('/admin/users/$id');
  }

  Future<void> approveUser(String id) async {
    await _dio.patch('/admin/users/$id/approve');
  }

  Future<void> unsuspendUser(String id) async {
    await _dio.patch('/admin/users/$id/unsuspend');
  }

  // Hard delete: only valid for a still-pending (unapproved) user.
  Future<void> denyUser(String id) async {
    await _dio.delete('/admin/users/$id/deny');
  }
}

final adminUserApiProvider = Provider<AdminUserApi>((ref) {
  return AdminUserApi(ref.watch(dioProvider));
});
