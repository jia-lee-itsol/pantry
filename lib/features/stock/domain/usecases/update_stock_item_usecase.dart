import '../entities/stock_item.dart';
import '../repositories/stock_repository.dart';

// ============================================
// Update Stock Item Use Case
// ============================================

/// Use case for updating an existing stock item in the inventory.
///
/// This use case encapsulates the business logic for modifying stock items.
/// It handles updates to quantity, expiration dates, categories, and other
/// item properties.
///
/// Usage:
/// ```dart
/// final useCase = UpdateStockItemUseCase(repository);
/// await useCase(updatedItem);
/// ```
class UpdateStockItemUseCase {
  /// The repository instance used to persist stock item updates
  final StockRepository repository;

  /// Creates a new instance of [UpdateStockItemUseCase].
  ///
  /// Parameters:
  /// - [repository]: The stock repository implementation to use
  UpdateStockItemUseCase(this.repository);

  /// Executes the use case to update an existing stock item.
  ///
  /// Parameters:
  /// - [item]: The [StockItem] with updated values
  ///
  /// The item is identified by its ID. All fields will be updated to match
  /// the provided item.
  ///
  /// Throws an exception if the operation fails or if the item doesn't exist.
  Future<void> call(StockItem item) {
    return repository.updateStockItem(item);
  }
}
