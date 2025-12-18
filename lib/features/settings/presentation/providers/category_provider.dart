import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/category_local_datasource.dart';
import '../../data/repositories_impl/category_repository_impl.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(CategoryLocalDataSource());
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  return await repository.getCategories();
});
