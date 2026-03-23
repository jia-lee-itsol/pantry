import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/add_category_usecase.dart';
import '../../domain/usecases/update_category_usecase.dart';
import '../../domain/usecases/delete_category_usecase.dart';
import '../../domain/usecases/reorder_categories_usecase.dart';
import '../../../../core/services/category_service.dart';

/// Provider for the category repository.
///
/// Exposes the [CategoryRepository] interface, implemented by the core
/// category service. Enables dependency injection for category operations.
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return ref.watch(categoryServiceProvider);
});

/// Provider for the get categories use case.
///
/// Creates an instance of [GetCategoriesUseCase] with the injected repository.
final getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return GetCategoriesUseCase(repository);
});

/// Provider for the add category use case.
///
/// Creates an instance of [AddCategoryUseCase] for adding new categories.
final addCategoryUseCaseProvider = Provider<AddCategoryUseCase>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return AddCategoryUseCase(repository);
});

/// Provider for the update category use case.
///
/// Creates an instance of [UpdateCategoryUseCase] for updating existing categories.
final updateCategoryUseCaseProvider = Provider<UpdateCategoryUseCase>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return UpdateCategoryUseCase(repository);
});

/// Provider for the delete category use case.
///
/// Creates an instance of [DeleteCategoryUseCase] for removing categories.
final deleteCategoryUseCaseProvider = Provider<DeleteCategoryUseCase>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return DeleteCategoryUseCase(repository);
});

/// Provider for the reorder categories use case.
///
/// Creates an instance of [ReorderCategoriesUseCase] for changing category order.
final reorderCategoriesUseCaseProvider = Provider<ReorderCategoriesUseCase>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return ReorderCategoriesUseCase(repository);
});

/// Provider for retrieving all categories.
///
/// A [FutureProvider] that executes the get categories use case and
/// returns the list of categories. Automatically handles loading and
/// error states through Riverpod's AsyncValue.
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final useCase = ref.watch(getCategoriesUseCaseProvider);
  return await useCase();
});
