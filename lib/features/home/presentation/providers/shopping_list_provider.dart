import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/shopping_list_item.dart';
import '../../domain/repositories/shopping_list_repository.dart';
import '../../data/datasources/shopping_list_local_datasource.dart';
import '../../data/repositories_impl/shopping_list_repository_impl.dart';

// DataSource Provider
final shoppingListDataSourceProvider = Provider<ShoppingListLocalDataSource>((ref) {
  return ShoppingListLocalDataSource();
});

// Repository Provider
final shoppingListRepositoryProvider = Provider<ShoppingListRepository>((ref) {
  final dataSource = ref.watch(shoppingListDataSourceProvider);
  return ShoppingListRepositoryImpl(dataSource);
});

class ShoppingListNotifier extends AsyncNotifier<List<ShoppingListItem>> {
  ShoppingListRepository get _repository => ref.read(shoppingListRepositoryProvider);

  @override
  Future<List<ShoppingListItem>> build() async {
    return _repository.getItems();
  }

  Future<void> addItem(ShoppingListItem item) async {
    await _repository.addItem(item);
    state = AsyncValue.data(await _repository.getItems());
  }

  Future<void> toggleItem(String id) async {
    final currentState = state.value ?? [];
    final updated = currentState.map((item) {
      if (item.id == id) {
        return item.copyWith(isCompleted: !item.isCompleted);
      }
      return item;
    }).toList();
    await _repository.saveItems(updated);
    state = AsyncValue.data(updated);
  }

  Future<void> deleteItem(String id) async {
    await _repository.deleteItem(id);
    final currentState = state.value ?? [];
    final updated = currentState.where((item) => item.id != id).toList();
    state = AsyncValue.data(updated);
  }

  Future<void> markAllCompleted() async {
    final currentState = state.value ?? [];
    final updated = currentState.map((item) => item.copyWith(isCompleted: true)).toList();
    await _repository.saveItems(updated);
    state = AsyncValue.data(updated);
  }

  Future<void> markAllIncomplete() async {
    final currentState = state.value ?? [];
    final updated = currentState.map((item) => item.copyWith(isCompleted: false)).toList();
    await _repository.saveItems(updated);
    state = AsyncValue.data(updated);
  }

  Future<void> updateItem(ShoppingListItem item) async {
    await _repository.updateItem(item);
    final currentState = state.value ?? [];
    final updated = currentState.map((existingItem) {
      if (existingItem.id == item.id) {
        return item;
      }
      return existingItem;
    }).toList();
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
