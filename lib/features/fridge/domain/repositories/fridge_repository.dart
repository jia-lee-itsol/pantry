import '../entities/fridge_item.dart';

/// Repository interface for fridge item operations.
///
/// This interface defines the contract for fridge item data access,
/// following the Repository pattern to abstract data sources from business logic.
///
/// ## Responsibilities:
/// - Provides a clean API for domain/presentation layers
/// - Abstracts underlying data source implementations (Firestore, local DB, etc.)
/// - Converts between domain entities ([FridgeItem]) and data models
///
/// ## Implementation:
/// The concrete implementation (FridgeRepositoryImpl) typically:
/// - Delegates to a data source (e.g., [FridgeFirestoreDataSource])
/// - Handles data model to entity conversion
/// - May implement caching strategies
///
/// ## Usage Example:
/// ```dart
/// class FridgeService {
///   final FridgeRepository repository;
///
///   FridgeService(this.repository);
///
///   Future<void> addMilk() async {
///     final milk = FridgeItem(
///       id: uuid.v4(),
///       name: 'Milk',
///       quantity: 1,
///       expiryDate: DateTime.now().add(Duration(days: 7)),
///       createdAt: DateTime.now(),
///     );
///     await repository.addFridgeItem(milk);
///   }
/// }
/// ```
abstract class FridgeRepository {
  /// Retrieves all fridge items.
  ///
  /// Returns a list of [FridgeItem] entities from the underlying data source.
  Future<List<FridgeItem>> getFridgeItems();

  /// Adds a new fridge item.
  ///
  /// Parameters:
  /// - [item]: The fridge item entity to add
  Future<void> addFridgeItem(FridgeItem item);

  /// Updates an existing fridge item.
  ///
  /// Parameters:
  /// - [item]: The fridge item entity with updated values
  Future<void> updateFridgeItem(FridgeItem item);

  /// Deletes a fridge item.
  ///
  /// Parameters:
  /// - [id]: The ID of the fridge item to delete
  Future<void> deleteFridgeItem(String id);
}
