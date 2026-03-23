import '../entities/shopping_list_item.dart';
import '../repositories/shopping_list_repository.dart';

// ============================================
// Update Shopping List Item Use Case
// ============================================

/// Use case for updating an existing shopping list item.
///
/// This use case encapsulates the business logic for modifying items
/// in the shopping list. It handles updating item properties such as
/// name, price, completion status, or category.
///
/// Example usage:
/// ```dart
/// final useCase = UpdateShoppingListItemUseCase(repository);
/// await useCase(updatedItem);
/// ```
class UpdateShoppingListItemUseCase {
  /// Repository instance for data access
  final ShoppingListRepository repository;

  /// Creates an instance of [UpdateShoppingListItemUseCase].
  ///
  /// Parameters:
  /// - [repository]: The shopping list repository to use for data operations
  UpdateShoppingListItemUseCase(this.repository);

  /// Executes the use case to update an existing shopping list item.
  ///
  /// Parameters:
  /// - [item]: The updated [ShoppingListItem] with the same ID as the item to replace
  ///
  /// Returns a [Future] that completes when the item has been successfully updated.
  ///
  /// This method can be called directly on the use case instance:
  /// ```dart
  /// await useCase(item);
  /// ```
  Future<void> call(ShoppingListItem item) {
    return repository.updateItem(item);
  }
}
