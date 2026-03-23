import '../models/stock_item_model.dart';

// ============================================
// Stock Data Source Interface
// ============================================

/// Abstract data source interface for stock item persistence operations.
///
/// This interface defines the contract for data source implementations
/// (local database, remote API, cloud storage, etc.). It operates at the
/// data layer level, working with [StockItemModel] instead of domain entities.
///
/// Implementations should handle:
/// - Raw data CRUD operations
/// - Data serialization/deserialization
/// - Connection management
/// - Basic error handling
///
/// Common implementations:
/// - [StockFirestoreDataSource]: Cloud Firestore backend
/// - Local database implementations (SQLite, Hive, etc.)
abstract class StockDataSource {
  /// Retrieves all stock items from the data source.
  ///
  /// Returns a list of [StockItemModel] instances representing all
  /// stored stock items.
  ///
  /// Throws an exception if the data retrieval operation fails.
  Future<List<StockItemModel>> getStockItems();

  /// Adds a new stock item to the data source.
  ///
  /// Parameters:
  /// - [item]: The [StockItemModel] to persist
  ///
  /// Throws an exception if the operation fails or if an item with
  /// the same ID already exists.
  Future<void> addStockItem(StockItemModel item);

  /// Updates an existing stock item in the data source.
  ///
  /// Parameters:
  /// - [item]: The [StockItemModel] with updated values
  ///
  /// The item is identified by its ID. All fields will be updated.
  ///
  /// Throws an exception if the operation fails or if the item doesn't exist.
  Future<void> updateStockItem(StockItemModel item);

  /// Deletes a stock item from the data source.
  ///
  /// Parameters:
  /// - [id]: The unique identifier of the item to delete
  ///
  /// Throws an exception if the operation fails or if the item doesn't exist.
  Future<void> deleteStockItem(String id);
}

