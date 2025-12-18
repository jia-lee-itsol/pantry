import '../../domain/entities/fridge_item.dart';
import '../../domain/repositories/fridge_repository.dart';
import '../datasources/fridge_local_datasource.dart';
import '../models/fridge_item_model.dart';

class FridgeRepositoryImpl implements FridgeRepository {
  final FridgeDataSource dataSource;

  FridgeRepositoryImpl(this.dataSource);

  @override
  Future<List<FridgeItem>> getFridgeItems() async {
    final items = await dataSource.getFridgeItems();
    return items;
  }

  @override
  Future<void> addFridgeItem(FridgeItem item) async {
    await dataSource.addFridgeItem(
      FridgeItemModel(
        id: item.id,
        name: item.name,
        quantity: item.quantity,
        category: item.category,
        expiryDate: item.expiryDate,
        createdAt: item.createdAt,
        updatedAt: item.updatedAt,
        isFrozen: item.isFrozen,
        targetQuantity: item.targetQuantity,
      ),
    );
  }

  @override
  Future<void> updateFridgeItem(FridgeItem item) async {
    await dataSource.updateFridgeItem(
      FridgeItemModel(
        id: item.id,
        name: item.name,
        quantity: item.quantity,
        category: item.category,
        expiryDate: item.expiryDate,
        createdAt: item.createdAt,
        updatedAt: item.updatedAt ?? DateTime.now(),
        isFrozen: item.isFrozen,
        targetQuantity: item.targetQuantity,
      ),
    );
  }

  @override
  Future<void> deleteFridgeItem(String id) async {
    await dataSource.deleteFridgeItem(id);
  }
}
