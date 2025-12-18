import '../models/fridge_item_model.dart';

abstract class FridgeDataSource {
  Future<List<FridgeItemModel>> getFridgeItems();
  Future<void> addFridgeItem(FridgeItemModel item);
  Future<void> updateFridgeItem(FridgeItemModel item);
  Future<void> deleteFridgeItem(String id);
}

