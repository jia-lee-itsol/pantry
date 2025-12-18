import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_datasource.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource _dataSource;

  CategoryRepositoryImpl(this._dataSource);

  @override
  Future<List<Category>> getCategories() async {
    return await _dataSource.getCategories();
  }

  @override
  Future<void> addCategory(Category category) async {
    final categories = await _dataSource.getCategories();
    final newCategory = CategoryModel(
      id: category.id,
      name: category.name,
      iconName: category.iconName,
      order: category.order,
      createdAt: category.createdAt,
    );
    categories.add(newCategory);
    await _dataSource.saveCategories(categories);
  }

  @override
  Future<void> updateCategory(Category category) async {
    final categories = await _dataSource.getCategories();
    final index = categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      categories[index] = CategoryModel(
        id: category.id,
        name: category.name,
        iconName: category.iconName,
        order: category.order,
        createdAt: category.createdAt,
      );
      await _dataSource.saveCategories(categories);
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    final categories = await _dataSource.getCategories();
    categories.removeWhere((c) => c.id == id);
    await _dataSource.saveCategories(categories);
  }

  @override
  Future<void> reorderCategories(List<Category> categories) async {
    final categoryModels = categories
        .map(
          (c) => CategoryModel(
            id: c.id,
            name: c.name,
            iconName: c.iconName,
            order: c.order,
            createdAt: c.createdAt,
          ),
        )
        .toList();
    await _dataSource.saveCategories(categoryModels);
  }
}
