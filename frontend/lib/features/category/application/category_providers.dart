import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/category_api.dart';
import '../data/models/category_model.dart';

/// Fetched once and shared by both the listener-side filter chips and the
/// admin upload form's category dropdown — categories rarely change, so a
/// plain [FutureProvider] (no mutation, no multi-phase state) is enough.
final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) {
  return ref.watch(categoryApiProvider).list();
});
