import '../entities/stock_item.dart';

// ============================================
// Stock Repository Interface
// ============================================

/// Abstract repository interface for stock item data operations.
///
/// This repository defines the contract for managing stock items in the pantry
/// inventory system. It follows the Repository pattern from clean architecture,
/// abstracting the data source details from the business logic.
///
/// Implementations of this interface should handle:
/// - Data persistence (local, remote, or hybrid)
/// - Error handling and retry logic
/// - Data synchronization between sources
/// - Offline capability management
abstract class StockRepository {
  /// Retrieves all stock items from the data source.
  ///
  /// Returns a list of all [StockItem] entities currently in the inventory.
  /// The list may be empty if no items exist.
  ///
  /// Throws an exception if the data retrieval fails.
  Future<List<StockItem>> getStockItems();

  /// Adds a new stock item to the inventory.
  ///
  /// Parameters:
  /// - [item]: The [StockItem] to be added
  ///
  /// Throws an exception if the operation fails or if an item with the
  /// same ID already exists.
  Future<void> addStockItem(StockItem item);

  /// Updates an existing stock item in the inventory.
  ///
  /// Parameters:
  /// - [item]: The [StockItem] with updated values
  ///
  /// The item is identified by its ID. All fields will be updated to match
  /// the provided item.
  ///
  /// Throws an exception if the operation fails or if the item doesn't exist.
  Future<void> updateStockItem(StockItem item);

  /// Deletes a stock item from the inventory.
  ///
  /// Parameters:
  /// - [id]: The unique identifier of the item to delete
  ///
  /// Throws an exception if the operation fails or if the item doesn't exist.
  Future<void> deleteStockItem(String id);
}

