import '../entities/shopping_list_item.dart';
import '../repositories/shopping_list_repository.dart';

// ============================================
// Get Shopping List Items Use Case
// ============================================

/// Use case for retrieving all shopping list items.
///
/// This use case encapsulates the business logic for fetching
/// all items from the shopping list. It delegates to the repository
/// for data access while providing a clean, single-purpose interface.
///
/// Example usage:
/// ```dart
/// final useCase = GetShoppingListItemsUseCase(repository);
/// final items = await useCase();
/// ```
class GetShoppingListItemsUseCase {
  /// Repository instance for data access
  final ShoppingListRepository repository;

  /// Creates an instance of [GetShoppingListItemsUseCase].
  ///
  /// Parameters:
  /// - [repository]: The shopping list repository to use for data operations
  GetShoppingListItemsUseCase(this.repository);

  /// Executes the use case to retrieve all shopping list items.
  ///
  /// Returns a [Future] that completes with a list of all [ShoppingListItem]s.
  ///
  /// This method can be called directly on the use case instance:
  /// ```dart
  /// final items = await useCase();
  /// ```
  Future<List<ShoppingListItem>> call() {
    return repository.getItems();
  }
}
