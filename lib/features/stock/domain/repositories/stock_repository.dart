import '../entities/stock_item.dart';

abstract class StockRepository {
  Future<List<StockItem>> getStockItems();
  Future<void> addStockItem(StockItem item);
  Future<void> updateStockItem(StockItem item);
  Future<void> deleteStockItem(String id);
}

