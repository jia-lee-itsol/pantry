import '../entities/category.dart';
import '../repositories/category_repository.dart';

class AddCategoryUseCase {
  final CategoryRepository repository;

  AddCategoryUseCase(this.repository);

  Future<void> call(Category category) {
    return repository.addCategory(category);
  }
}
