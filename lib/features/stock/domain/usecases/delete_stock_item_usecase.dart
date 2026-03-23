import '../repositories/stock_repository.dart';

// ============================================
// Delete Stock Item Use Case
// ============================================

/// Use case for removing a stock item from the inventory.
///
/// This use case encapsulates the business logic for deleting stock items.
/// It ensures proper cleanup and follows the application's deletion policies.
///
/// Usage:
/// ```dart
/// final useCase = DeleteStockItemUseCase(repository);
/// await useCase('item-id-123');
/// ```
class DeleteStockItemUseCase {
  /// The repository instance used to delete stock items
  final StockRepository repository;

  /// Creates a new instance of [DeleteStockItemUseCase].
  ///
  /// Parameters:
  /// - [repository]: The stock repository implementation to use
  DeleteStockItemUseCase(this.repository);

  /// Executes the use case to delete a stock item.
  ///
  /// Parameters:
  /// - [id]: The unique identifier of the item to delete
  ///
  /// Throws an exception if the operation fails or if the item doesn't exist.
  Future<void> call(String id) {
    return repository.deleteStockItem(id);
  }
}
