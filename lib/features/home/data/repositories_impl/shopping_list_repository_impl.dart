import '../../domain/entities/shopping_list_item.dart';
import '../../domain/repositories/shopping_list_repository.dart';
import '../datasources/shopping_list_local_datasource.dart';
import '../models/shopping_list_item_model.dart';

class ShoppingListRepositoryImpl implements ShoppingListRepository {
  final ShoppingListLocalDataSource dataSource;

  ShoppingListRepositoryImpl(this.dataSource);

  @override
  Future<List<ShoppingListItem>> getItems() async {
    final models = await dataSource.getItems();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> addItem(ShoppingListItem item) async {
    final currentItems = await dataSource.getItems();
    final model = ShoppingListItemModel.fromEntity(item);
    currentItems.add(model);
    await dataSource.saveItems(currentItems);
  }

  @override
  Future<void> updateItem(ShoppingListItem item) async {
    final currentItems = await dataSource.getItems();
    final updatedItems = currentItems.map((existingItem) {
      if (existingItem.id == item.id) {
        return ShoppingListItemModel.fromEntity(item);
      }
      return existingItem;
    }).toList();
    await dataSource.saveItems(updatedItems);
  }

  @override
  Future<void> deleteItem(String id) async {
    final currentItems = await dataSource.getItems();
    final updatedItems = currentItems.where((item) => item.id != id).toList();
    await dataSource.saveItems(updatedItems);
  }

  @override
  Future<void> saveItems(List<ShoppingListItem> items) async {
    final models = items.map((item) => ShoppingListItemModel.fromEntity(item)).toList();
    await dataSource.saveItems(models);
  }
}
