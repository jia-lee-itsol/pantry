import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/shopping_list_item.dart';
import '../../domain/repositories/shopping_list_repository.dart';
import '../../../../core/services/shopping_list_service.dart';

// ============================================
// Shopping List Providers
// ============================================

/// Provides access to the shopping list repository.
///
/// This provider wraps the core shopping list service and exposes it
/// as a repository for use in the shopping list feature.
///
/// The repository is obtained from the core service layer to ensure
/// consistent data access across the application.
final shoppingListRepositoryProvider = Provider<ShoppingListRepository>((ref) {
  return ref.watch(shoppingListServiceProvider);
});

// ============================================
// Shopping List State Notifier
// ============================================

/// State notifier for managing shopping list items.
///
/// This notifier handles all state management for the shopping list feature,
/// including CRUD operations, item toggling, and bulk operations.
///
/// State is maintained as an [AsyncValue] of shopping list items,
/// allowing proper handling of loading and error states in the UI.
///
/// Key responsibilities:
/// - Load and cache shopping list items
/// - Add, update, and delete individual items
/// - Toggle item completion status
/// - Bulk mark items as completed or incomplete
/// - Filter items by category
class ShoppingListNotifier extends AsyncNotifier<List<ShoppingListItem>> {
  /// Gets the repository instance from the provider
  ShoppingListRepository get _repository => ref.read(shoppingListRepositoryProvider);

  /// Builds the initial state by loading items from the repository.
  ///
  /// This method is called automatically when the provider is first accessed.
  ///
  /// Returns a [Future] that completes with the list of shopping list items.
  @override
  Future<List<ShoppingListItem>> build() async {
    return _repository.getItems();
  }

  /// Adds a new item to the shopping list.
  ///
  /// Parameters:
  /// - [item]: The [ShoppingListItem] to add
  ///
  /// Returns a [Future] that completes when the item has been added
  /// and the state has been refreshed.
  Future<void> addItem(ShoppingListItem item) async {
    await _repository.addItem(item);
    state = AsyncValue.data(await _repository.getItems());
  }

  /// Toggles the completion status of an item.
  ///
  /// This method finds the item by ID and flips its [isCompleted] status.
  ///
  /// Parameters:
  /// - [id]: The unique identifier of the item to toggle
  ///
  /// Returns a [Future] that completes when the item has been toggled
  /// and saved to storage.
  Future<void> toggleItem(String id) async {
    final currentState = state.value ?? [];
    final updated = currentState.map((item) {
      if (item.id == id) {
        return item.copyWith(isCompleted: !item.isCompleted);
      }
      return item;
    }).toList();
    await _repository.saveItems(updated);
    state = AsyncValue.data(updated);
  }

  /// Deletes an item from the shopping list.
  ///
  /// Parameters:
  /// - [id]: The unique identifier of the item to delete
  ///
  /// Returns a [Future] that completes when the item has been deleted
  /// and the state has been updated.
  Future<void> deleteItem(String id) async {
    await _repository.deleteItem(id);
    final currentState = state.value ?? [];
    final updated = currentState.where((item) => item.id != id).toList();
    state = AsyncValue.data(updated);
  }

  /// Marks all shopping list items as completed.
  ///
  /// This is useful for bulk operations, such as marking all items
  /// as purchased after a shopping trip.
  ///
  /// Returns a [Future] that completes when all items have been marked
  /// complete and saved to storage.
  Future<void> markAllCompleted() async {
    final currentState = state.value ?? [];
    final updated = currentState.map((item) => item.copyWith(isCompleted: true)).toList();
    await _repository.saveItems(updated);
    state = AsyncValue.data(updated);
  }

  /// Marks all shopping list items as incomplete.
  ///
  /// This is useful for resetting the shopping list for a new shopping trip.
  ///
  /// Returns a [Future] that completes when all items have been marked
  /// incomplete and saved to storage.
  Future<void> markAllIncomplete() async {
    final currentState = state.value ?? [];
    final updated = currentState.map((item) => item.copyWith(isCompleted: false)).toList();
    await _repository.saveItems(updated);
    state = AsyncValue.data(updated);
  }

  /// Updates an existing shopping list item.
  ///
  /// This method replaces the item with the same ID with the provided
  /// updated item.
  ///
  /// Parameters:
  /// - [item]: The updated [ShoppingListItem]
  ///
  /// Returns a [Future] that completes when the item has been updated
  /// and the state has been refreshed.
  Future<void> updateItem(ShoppingListItem item) async {
    await _repository.updateItem(item);
    final currentState = state.value ?? [];
    final updated = currentState.map((existingItem) {
      if (existingItem.id == item.id) {
        return item;
      }
      return existingItem;
    }).toList();
    state = AsyncValue.data(updated);
  }

  /// Filters shopping list items by category.
  ///
  /// Parameters:
  /// - [category]: The category to filter by ('fridge' or 'stock')
  ///
  /// Returns a list of [ShoppingListItem]s matching the specified category.
  ///
  /// Example:
  /// ```dart
  /// final fridgeItems = notifier.getItemsByCategory('fridge');
  /// ```
  List<ShoppingListItem> getItemsByCategory(String category) {
    final currentState = state.value ?? [];
    return currentState.where((item) => item.category == category).toList();
  }
}

/// Provider for shopping list state and operations.
///
/// This provider exposes the [ShoppingListNotifier] which manages
/// the shopping list state and provides methods for manipulating items.
///
/// Usage:
/// ```dart
/// // Watch the shopping list
/// final shoppingList = ref.watch(shoppingListProvider);
///
/// // Perform operations
/// ref.read(shoppingListProvider.notifier).addItem(newItem);
/// ref.read(shoppingListProvider.notifier).toggleItem(itemId);
/// ```
final shoppingListProvider =
    AsyncNotifierProvider<ShoppingListNotifier, List<ShoppingListItem>>(
      () => ShoppingListNotifier(),
    );
