import '../entities/shopping_list_item.dart';

// ============================================
// Shopping List Repository Interface
// ============================================

/// Repository interface for managing shopping list data operations.
///
/// This repository defines the contract for accessing and manipulating
/// shopping list items. It follows the repository pattern to abstract
/// data source details from the business logic layer.
///
/// Implementations should handle persistence through appropriate data sources
/// (e.g., local storage, remote API).
abstract class ShoppingListRepository {
  /// Retrieves all shopping list items.
  ///
  /// Returns a [Future] that completes with a list of all [ShoppingListItem]s
  /// currently stored in the data source.
  ///
  /// Example:
  /// ```dart
  /// final items = await repository.getItems();
  /// ```
  Future<List<ShoppingListItem>> getItems();

  /// Adds a new item to the shopping list.
  ///
  /// Parameters:
  /// - [item]: The [ShoppingListItem] to be added
  ///
  /// Returns a [Future] that completes when the item has been successfully added.
  ///
  /// Example:
  /// ```dart
  /// await repository.addItem(newItem);
  /// ```
  Future<void> addItem(ShoppingListItem item);

  /// Updates an existing shopping list item.
  ///
  /// Parameters:
  /// - [item]: The updated [ShoppingListItem] with the same ID as the item to replace
  ///
  /// Returns a [Future] that completes when the item has been successfully updated.
  ///
  /// Example:
  /// ```dart
  /// await repository.updateItem(updatedItem);
  /// ```
  Future<void> updateItem(ShoppingListItem item);

  /// Deletes an item from the shopping list.
  ///
  /// Parameters:
  /// - [id]: The unique identifier of the item to delete
  ///
  /// Returns a [Future] that completes when the item has been successfully deleted.
  ///
  /// Example:
  /// ```dart
  /// await repository.deleteItem('item-123');
  /// ```
  Future<void> deleteItem(String id);

  /// Replaces all shopping list items with the provided list.
  ///
  /// This method overwrites the entire shopping list with new items.
  /// Use this for bulk operations like reordering or clearing the list.
  ///
  /// Parameters:
  /// - [items]: The complete list of [ShoppingListItem]s to save
  ///
  /// Returns a [Future] that completes when all items have been successfully saved.
  ///
  /// Example:
  /// ```dart
  /// await repository.saveItems(reorderedItems);
  /// ```
  Future<void> saveItems(List<ShoppingListItem> items);
}
