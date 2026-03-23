import '../repositories/shopping_list_repository.dart';

// ============================================
// Delete Shopping List Item Use Case
// ============================================

/// Use case for deleting an item from the shopping list.
///
/// This use case encapsulates the business logic for removing items
/// from the shopping list. It ensures proper deletion through the
/// repository layer using the item's unique identifier.
///
/// Example usage:
/// ```dart
/// final useCase = DeleteShoppingListItemUseCase(repository);
/// await useCase('item-123');
/// ```
class DeleteShoppingListItemUseCase {
  /// Repository instance for data access
  final ShoppingListRepository repository;

  /// Creates an instance of [DeleteShoppingListItemUseCase].
  ///
  /// Parameters:
  /// - [repository]: The shopping list repository to use for data operations
  DeleteShoppingListItemUseCase(this.repository);

  /// Executes the use case to delete a shopping list item.
  ///
  /// Parameters:
  /// - [id]: The unique identifier of the item to delete
  ///
  /// Returns a [Future] that completes when the item has been successfully deleted.
  ///
  /// This method can be called directly on the use case instance:
  /// ```dart
  /// await useCase(itemId);
  /// ```
  Future<void> call(String id) {
    return repository.deleteItem(id);
  }
}
