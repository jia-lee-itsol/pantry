import '../entities/stock_item.dart';
import '../repositories/stock_repository.dart';

// ============================================
// Add Stock Item Use Case
// ============================================

/// Use case for adding a new stock item to the inventory.
///
/// This use case encapsulates the business logic for creating new stock items.
/// It ensures that the item creation follows the application's business rules
/// and constraints.
///
/// Usage:
/// ```dart
/// final useCase = AddStockItemUseCase(repository);
/// await useCase(newItem);
/// ```
class AddStockItemUseCase {
  /// The repository instance used to persist stock items
  final StockRepository repository;

  /// Creates a new instance of [AddStockItemUseCase].
  ///
  /// Parameters:
  /// - [repository]: The stock repository implementation to use
  AddStockItemUseCase(this.repository);

  /// Executes the use case to add a new stock item.
  ///
  /// Parameters:
  /// - [item]: The [StockItem] to be added to the inventory
  ///
  /// Throws an exception if the operation fails or if an item with the
  /// same ID already exists.
  Future<void> call(StockItem item) {
    return repository.addStockItem(item);
  }
}
