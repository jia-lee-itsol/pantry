import '../../domain/entities/shopping_list_item.dart';
import '../../domain/repositories/shopping_list_repository.dart';
import '../datasources/shopping_list_local_datasource.dart';
import '../models/shopping_list_item_model.dart';

// ============================================
// Shopping List Repository Implementation
// ============================================

/// Implementation of [ShoppingListRepository] using local storage.
///
/// This repository implementation manages shopping list data using
/// [ShoppingListLocalDataSource] for persistence. It handles conversion
/// between domain entities and data models, and implements all CRUD
/// operations defined in the repository interface.
///
/// Responsibilities:
/// - Convert between domain entities and data models
/// - Coordinate data source operations
/// - Implement business logic for shopping list management
class ShoppingListRepositoryImpl implements ShoppingListRepository {
  /// Local data source for shopping list operations
  final ShoppingListLocalDataSource dataSource;

  /// Creates an instance of [ShoppingListRepositoryImpl].
  ///
  /// Parameters:
  /// - [dataSource]: The local data source to use for persistence
  ShoppingListRepositoryImpl(this.dataSource);

  /// Retrieves all shopping list items.
  ///
  /// Loads items from the data source and converts them to domain entities.
  ///
  /// Returns a [Future] that completes with a list of [ShoppingListItem] entities.
  @override
  Future<List<ShoppingListItem>> getItems() async {
    final models = await dataSource.getItems();
    return models.map((model) => model.toEntity()).toList();
  }

  /// Adds a new item to the shopping list.
  ///
  /// This method:
  /// 1. Loads current items from storage
  /// 2. Converts the new entity to a data model
  /// 3. Adds it to the list
  /// 4. Saves the updated list back to storage
  ///
  /// Parameters:
  /// - [item]: The [ShoppingListItem] entity to add
  ///
  /// Returns a [Future] that completes when the operation is done.
  @override
  Future<void> addItem(ShoppingListItem item) async {
    final currentItems = await dataSource.getItems();
    final model = ShoppingListItemModel.fromEntity(item);
    currentItems.add(model);
    await dataSource.saveItems(currentItems);
  }

  /// Updates an existing shopping list item.
  ///
  /// This method:
  /// 1. Loads current items from storage
  /// 2. Finds the item with matching ID
  /// 3. Replaces it with the updated entity
  /// 4. Saves the updated list back to storage
  ///
  /// Parameters:
  /// - [item]: The updated [ShoppingListItem] entity
  ///
  /// Returns a [Future] that completes when the operation is done.
  @override
  Future<void> updateItem(ShoppingListItem item) async {
    final currentItems = await dataSource.getItems();
    final updatedItems = currentItems.map((existingItem) {
      if (existingItem.id == item.id) {
        return ShoppingListItemModel.fromEntity(item);
      }
      return existingItem;
    }).toList();
    await dataSource.saveItems(updatedItems);
  }

  /// Deletes an item from the shopping list.
  ///
  /// This method:
  /// 1. Loads current items from storage
  /// 2. Filters out the item with the specified ID
  /// 3. Saves the updated list back to storage
  ///
  /// Parameters:
  /// - [id]: The unique identifier of the item to delete
  ///
  /// Returns a [Future] that completes when the operation is done.
  @override
  Future<void> deleteItem(String id) async {
    final currentItems = await dataSource.getItems();
    final updatedItems = currentItems.where((item) => item.id != id).toList();
    await dataSource.saveItems(updatedItems);
  }

  /// Replaces all shopping list items with a new list.
  ///
  /// This method converts all entities to models and saves them,
  /// replacing the entire existing list.
  ///
  /// Parameters:
  /// - [items]: The complete list of [ShoppingListItem] entities to save
  ///
  /// Returns a [Future] that completes when the operation is done.
  @override
  Future<void> saveItems(List<ShoppingListItem> items) async {
    final models = items.map((item) => ShoppingListItemModel.fromEntity(item)).toList();
    await dataSource.saveItems(models);
  }
}
