import '../entities/category.dart';
import '../repositories/category_repository.dart';

class ReorderCategoriesUseCase {
  final CategoryRepository repository;

  ReorderCategoriesUseCase(this.repository);

  Future<void> call(List<Category> categories) {
    return repository.reorderCategories(categories);
  }
}
