import '../models/stock_item_model.dart';

abstract class StockDataSource {
  Future<List<StockItemModel>> getStockItems();
  Future<void> addStockItem(StockItemModel item);
  Future<void> updateStockItem(StockItemModel item);
  Future<void> deleteStockItem(String id);
}

