import '../../domain/entities/stock_item.dart';
import '../../domain/repositories/stock_repository.dart';
import '../datasources/stock_local_datasource.dart';
import '../models/stock_item_model.dart';

class StockRepositoryImpl implements StockRepository {
  final StockDataSource dataSource;

  StockRepositoryImpl(this.dataSource);

  @override
  Future<List<StockItem>> getStockItems() async {
    final items = await dataSource.getStockItems();
    return items;
  }

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

  @override
  Future<void> deleteStockItem(String id) async {
    await dataSource.deleteStockItem(id);
  }
}
