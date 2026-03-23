import '../entities/category.dart';

/// Repository interface for category management operations.
///
/// This repository defines the contract for CRUD operations on product
/// categories, including creating, reading, updating, deleting, and
/// reordering categories.
abstract class CategoryRepository {
  /// Retrieves all categories from storage.
  ///
  /// Returns a list of [Category] objects ordered by their order property.
  /// Throws an exception if the operation fails.
  Future<List<Category>> getCategories();

  /// Adds a new category to storage.
  ///
  /// Parameters:
  ///   [category] - The category to add
  ///
  /// Throws an exception if the operation fails.
  Future<void> addCategory(Category category);

  /// Updates an existing category in storage.
  ///
  /// Parameters:
  ///   [category] - The category with updated information
  ///
  /// Throws an exception if the operation fails.
  Future<void> updateCategory(Category category);

  /// Deletes a category from storage.
  ///
  /// Parameters:
  ///   [id] - The unique identifier of the category to delete
  ///
  /// Throws an exception if the operation fails.
  Future<void> deleteCategory(String id);

  /// Reorders categories by updating their order values.
  ///
  /// Parameters:
  ///   [categories] - The list of categories in the desired order
  ///
  /// Throws an exception if the operation fails.
  Future<void> reorderCategories(List<Category> categories);
}
