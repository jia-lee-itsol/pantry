import '../../features/fridge/domain/entities/fridge_item.dart';
import '../../features/fridge/domain/repositories/fridge_repository.dart';
import '../../features/fridge/data/models/fridge_item_model.dart';
import 'mock_data_service.dart';

class MockFridgeRepository implements FridgeRepository {
  static final List<FridgeItemModel> _items = [
    ...MockDataService.getMockFridgeItems(),
  ];

  @override
  Future<List<FridgeItem>> getFridgeItems() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _items;
  }

  @override
  Future<void> addFridgeItem(FridgeItem item) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _items.add(
      FridgeItemModel(
        id: item.id,
        name: item.name,
        quantity: item.quantity,
        category: item.category,
        expiryDate: item.expiryDate,
        createdAt: item.createdAt,
        updatedAt: item.updatedAt,
        isFrozen: item.isFrozen,
      ),
    );
  }

  @override
  Future<void> updateFridgeItem(FridgeItem item) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index] = FridgeItemModel(
        id: item.id,
        name: item.name,
        quantity: item.quantity,
        category: item.category,
        expiryDate: item.expiryDate,
        createdAt: item.createdAt,
        updatedAt: item.updatedAt ?? DateTime.now(),
        isFrozen: item.isFrozen,
      );
    }
  }

  @override
  Future<void> deleteFridgeItem(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _items.removeWhere((item) => item.id == id);
  }
}
