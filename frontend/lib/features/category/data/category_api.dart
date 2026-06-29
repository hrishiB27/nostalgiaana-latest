import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import 'models/category_model.dart';

/// Thin wrapper over the public `/api/categories` endpoint.
class CategoryApi {
  const CategoryApi(this._dio);

  final Dio _dio;

  Future<List<CategoryModel>> list() async {
    final response = await _dio.get<List<dynamic>>('/categories');
    return response.data!
        .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

final categoryApiProvider = Provider<CategoryApi>((ref) {
  return CategoryApi(ref.watch(dioProvider));
});
