import '../../domain/entities/stock_item.dart';
import '../../domain/repositories/stock_repository.dart';
import '../datasources/stock_local_datasource.dart';
import '../models/stock_item_model.dart';

// ============================================
// Stock Repository Implementation
// ============================================

/// Concrete implementation of the [StockRepository] interface.
///
/// This class bridges the domain layer and data layer by implementing
/// the repository pattern. It coordinates data operations through a
/// [StockDataSource] while maintaining clean architecture boundaries.
///
/// **Key Responsibilities:**
/// - Converting between domain entities and data models
/// - Delegating persistence operations to data sources
/// - Maintaining consistency across layers
/// - Abstracting data source implementation details
///
/// **Data Flow:**
/// ```
/// Domain Layer (StockItem)
///       ↓
/// Repository (converts to/from models)
///       ↓
/// Data Source (StockItemModel)
///       ↓
/// Storage (Firestore, SQLite, etc.)
/// ```
class StockRepositoryImpl implements StockRepository {
  /// The data source used for persistence operations
  final StockDataSource dataSource;

  /// Creates a new [StockRepositoryImpl] instance.
  ///
  /// Parameters:
  /// - [dataSource]: The data source implementation to use (Firestore, local DB, etc.)
  StockRepositoryImpl(this.dataSource);

  // ============================================
  // Repository Methods - Read Operations
  // ============================================

  /// Retrieves all stock items from the data source.
  ///
  /// Fetches items from the underlying data source and returns them
  /// as domain entities. The models returned from the data source are
  /// already compatible with [StockItem] due to the inheritance relationship.
  ///
  /// Returns a list of all stock items.
  ///
  /// Throws an exception if the data retrieval fails.
  @override
  Future<List<StockItem>> getStockItems() async {
    final items = await dataSource.getStockItems();
    return items;
  }

  // ============================================
  // Repository Methods - Write Operations
  // ============================================

  /// Adds a new stock item to the data source.
  ///
  /// Converts the domain [StockItem] entity to a [StockItemModel]
  /// before persisting it through the data source.
  ///
  /// Parameters:
  /// - [item]: The stock item entity to add
  ///
  /// Throws an exception if the operation fails.
  @override
  Future<void> addStockItem(StockItem item) async {
    await dataSource.addStockItem(
      StockItemModel(
        id: item.id,
        name: item.name,
        quantity: item.quantity,
        lastUpdated: item.lastUpdated,
        category: item.category,
        expiryDate: item.expiryDate,
        targetQuantity: item.targetQuantity,
      ),
    );
  }

  /// Updates an existing stock item in the data source.
  ///
  /// Converts the domain [StockItem] entity to a [StockItemModel]
  /// before updating it through the data source.
  ///
  /// Parameters:
  /// - [item]: The stock item entity with updated values
  ///
  /// Throws an exception if the operation fails or if the item doesn't exist.
  @override
  Future<void> updateStockItem(StockItem item) async {
    await dataSource.updateStockItem(
      StockItemModel(
        id: item.id,
        name: item.name,
        quantity: item.quantity,
        lastUpdated: item.lastUpdated,
        category: item.category,
        expiryDate: item.expiryDate,
        targetQuantity: item.targetQuantity,
      ),
    );
  }

  /// Deletes a stock item from the data source.
  ///
  /// Parameters:
  /// - [id]: The unique identifier of the item to delete
  ///
  /// Throws an exception if the operation fails or if the item doesn't exist.
  @override
  Future<void> deleteStockItem(String id) async {
    await dataSource.deleteStockItem(id);
  }
}
