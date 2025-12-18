import '../entities/fridge_item.dart';

abstract class FridgeRepository {
  Future<List<FridgeItem>> getFridgeItems();
  Future<void> addFridgeItem(FridgeItem item);
  Future<void> updateFridgeItem(FridgeItem item);
  Future<void> deleteFridgeItem(String id);
}
