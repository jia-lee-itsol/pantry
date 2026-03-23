import '../models/fridge_item_model.dart';

/// Abstract data source interface for fridge item operations.
///
/// This interface defines the contract for all fridge data sources,
/// supporting both remote (Firestore) and local storage implementations.
///
/// ## Implementations:
/// - [FridgeFirestoreDataSource]: Cloud storage via Firebase Firestore
/// - Additional implementations could include local database (SQLite, Hive, etc.)
///
/// ## Usage:
/// This abstraction enables:
/// - Dependency injection for testability
/// - Easy switching between storage backends
/// - Mock implementations for testing
///
/// Example:
/// ```dart
/// class MyRepository {
///   final FridgeDataSource dataSource;
///
///   MyRepository(this.dataSource);
///
///   Future<void> addItem(FridgeItem item) {
///     final model = FridgeItemModel.fromEntity(item);
///     return dataSource.addFridgeItem(model);
///   }
/// }
/// ```
abstract class FridgeDataSource {
  /// Retrieves all fridge items from the data source.
  ///
  /// Returns a list of [FridgeItemModel] objects.
  Future<List<FridgeItemModel>> getFridgeItems();

  /// Adds a new fridge item to the data source.
  ///
  /// Parameters:
  /// - [item]: The fridge item to add
  Future<void> addFridgeItem(FridgeItemModel item);

  /// Updates an existing fridge item in the data source.
  ///
  /// Parameters:
  /// - [item]: The fridge item with updated values
  Future<void> updateFridgeItem(FridgeItemModel item);

  /// Deletes a fridge item from the data source.
  ///
  /// Parameters:
  /// - [id]: The ID of the fridge item to delete
  Future<void> deleteFridgeItem(String id);
}

