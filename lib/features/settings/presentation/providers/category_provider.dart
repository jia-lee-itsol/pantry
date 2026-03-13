import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/category_local_datasource.dart';
import '../../data/repositories_impl/category_repository_impl.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/add_category_usecase.dart';
import '../../domain/usecases/update_category_usecase.dart';
import '../../domain/usecases/delete_category_usecase.dart';
import '../../domain/usecases/reorder_categories_usecase.dart';

// DataSource Provider
final categoryDataSourceProvider = Provider<CategoryLocalDataSource>((ref) {
  return CategoryLocalDataSource();
});

// Repository Provider
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final dataSource = ref.watch(categoryDataSourceProvider);
  return CategoryRepositoryImpl(dataSource);
});

// UseCase Providers
final getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return GetCategoriesUseCase(repository);
});

final addCategoryUseCaseProvider = Provider<AddCategoryUseCase>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return AddCategoryUseCase(repository);
});

final updateCategoryUseCaseProvider = Provider<UpdateCategoryUseCase>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return UpdateCategoryUseCase(repository);
});

final deleteCategoryUseCaseProvider = Provider<DeleteCategoryUseCase>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return DeleteCategoryUseCase(repository);
});

final reorderCategoriesUseCaseProvider = Provider<ReorderCategoriesUseCase>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return ReorderCategoriesUseCase(repository);
});

// Categories Provider (uses GetCategoriesUseCase)
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final useCase = ref.watch(getCategoriesUseCaseProvider);
  return await useCase();
});
