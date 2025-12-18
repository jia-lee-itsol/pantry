import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/shopping_list_item.dart';
import '../../data/datasources/shopping_list_local_datasource.dart';
import '../../data/models/shopping_list_item_model.dart';

class ShoppingListNotifier extends AsyncNotifier<List<ShoppingListItem>> {
  final _dataSource = ShoppingListLocalDataSource();

  @override
  Future<List<ShoppingListItem>> build() async {
    final models = await _dataSource.getItems();
    return models.map((model) => model.toEntity()).toList();
  }

  Future<void> addItem(ShoppingListItem item) async {
    final currentState = state.value ?? [];
    final model = ShoppingListItemModel.fromEntity(item);
    final models = currentState.map((i) => ShoppingListItemModel.fromEntity(i)).toList();
    models.add(model);
    await _dataSource.saveItems(models);
    state = AsyncValue.data(models.map((m) => m.toEntity()).toList());
  }

  Future<void> toggleItem(String id) async {
    final currentState = state.value ?? [];
    final updated = currentState.map((item) {
      if (item.id == id) {
        return item.copyWith(isCompleted: !item.isCompleted);
      }
      return item;
    }).toList();
    final models = updated.map((i) => ShoppingListItemModel.fromEntity(i)).toList();
    await _dataSource.saveItems(models);
    state = AsyncValue.data(updated);
  }

  Future<void> deleteItem(String id) async {
    final currentState = state.value ?? [];
    final updated = currentState.where((item) => item.id != id).toList();
    final models = updated.map((i) => ShoppingListItemModel.fromEntity(i)).toList();
    await _dataSource.saveItems(models);
    state = AsyncValue.data(updated);
  }

  Future<void> markAllCompleted() async {
    final currentState = state.value ?? [];
    final updated = currentState.map((item) => item.copyWith(isCompleted: true)).toList();
    final models = updated.map((i) => ShoppingListItemModel.fromEntity(i)).toList();
    await _dataSource.saveItems(models);
    state = AsyncValue.data(updated);
  }

  Future<void> markAllIncomplete() async {
    final currentState = state.value ?? [];
    final updated = currentState.map((item) => item.copyWith(isCompleted: false)).toList();
    final models = updated.map((i) => ShoppingListItemModel.fromEntity(i)).toList();
    await _dataSource.saveItems(models);
    state = AsyncValue.data(updated);
  }

  Future<void> updateItem(ShoppingListItem item) async {
    final currentState = state.value ?? [];
    final updated = currentState.map((existingItem) {
      if (existingItem.id == item.id) {
        return item;
      }
      return existingItem;
    }).toList();
    final models = updated.map((i) => ShoppingListItemModel.fromEntity(i)).toList();
    await _dataSource.saveItems(models);
    state = AsyncValue.data(updated);
  }

  List<ShoppingListItem> getItemsByCategory(String category) {
    final currentState = state.value ?? [];
    return currentState.where((item) => item.category == category).toList();
  }
}

final shoppingListProvider =
    AsyncNotifierProvider<ShoppingListNotifier, List<ShoppingListItem>>(
      () => ShoppingListNotifier(),
    );
