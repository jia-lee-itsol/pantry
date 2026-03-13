import '../entities/shopping_list_item.dart';
import '../repositories/shopping_list_repository.dart';

class GetShoppingListItemsUseCase {
  final ShoppingListRepository repository;

  GetShoppingListItemsUseCase(this.repository);

  Future<List<ShoppingListItem>> call() {
    return repository.getItems();
  }
}
