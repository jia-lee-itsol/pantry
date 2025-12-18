import '../../features/stock/domain/entities/stock_item.dart';
import '../../features/stock/domain/repositories/stock_repository.dart';
import '../../features/stock/data/models/stock_item_model.dart';
import 'mock_data_service.dart';

class MockStockRepository implements StockRepository {
  static final List<StockItemModel> _items = [
    ...MockDataService.getMockStockItems(),
  ];

  @override
  Future<List<StockItem>> getStockItems() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _items;
  }

  @override
  Future<void> addStockItem(StockItem item) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _items.add(
      StockItemModel(
        id: item.id,
        name: item.name,
        quantity: item.quantity,
        lastUpdated: item.lastUpdated,
        category: item.category,
        expiryDate: item.expiryDate,
      ),
    );
  }

  @override
  Future<void> updateStockItem(StockItem item) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index] = StockItemModel(
        id: item.id,
        name: item.name,
        quantity: item.quantity,
        lastUpdated: item.lastUpdated,
        category: item.category,
        expiryDate: item.expiryDate,
      );
    }
  }

  @override
  Future<void> deleteStockItem(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _items.removeWhere((item) => item.id == id);
  }
}
