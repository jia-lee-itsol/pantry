import '../entities/stock_item.dart';
import '../repositories/stock_repository.dart';

// ============================================
// Get Stock Items Use Case
// ============================================

/// Use case for retrieving all stock items from the inventory.
///
/// This use case encapsulates the business logic for fetching all stock items.
/// It follows the Single Responsibility Principle by focusing solely on the
/// retrieval operation.
///
/// Usage:
/// ```dart
/// final useCase = GetStockItemsUseCase(repository);
/// final items = await useCase();
/// ```
class GetStockItemsUseCase {
  /// The repository instance used to fetch stock items
  final StockRepository repository;

  /// Creates a new instance of [GetStockItemsUseCase].
  ///
  /// Parameters:
  /// - [repository]: The stock repository implementation to use
  GetStockItemsUseCase(this.repository);

  /// Executes the use case to retrieve all stock items.
  ///
  /// Returns a list of all [StockItem] entities in the inventory.
  /// The list may be empty if no items exist.
  ///
  /// Throws an exception if the retrieval operation fails.
  Future<List<StockItem>> call() {
    return repository.getStockItems();
  }
}

