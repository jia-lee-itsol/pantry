import '../entities/shopping_list_item.dart';
import '../repositories/shopping_list_repository.dart';

// ============================================
// Add Shopping List Item Use Case
// ============================================

/// Use case for adding a new item to the shopping list.
///
/// This use case encapsulates the business logic for adding items
/// to the shopping list. It ensures that items are properly validated
/// and stored through the repository layer.
///
/// Example usage:
/// ```dart
/// final useCase = AddShoppingListItemUseCase(repository);
/// await useCase(newItem);
/// ```
class AddShoppingListItemUseCase {
  /// Repository instance for data access
  final ShoppingListRepository repository;

  /// Creates an instance of [AddShoppingListItemUseCase].
  ///
  /// Parameters:
  /// - [repository]: The shopping list repository to use for data operations
  AddShoppingListItemUseCase(this.repository);

  /// Executes the use case to add a new shopping list item.
  ///
  /// Parameters:
  /// - [item]: The [ShoppingListItem] to add to the list
  ///
  /// Returns a [Future] that completes when the item has been successfully added.
  ///
  /// This method can be called directly on the use case instance:
  /// ```dart
  /// await useCase(item);
  /// ```
  Future<void> call(ShoppingListItem item) {
    return repository.addItem(item);
  }
}
