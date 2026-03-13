import '../entities/shopping_list_item.dart';
import '../repositories/shopping_list_repository.dart';

class AddShoppingListItemUseCase {
  final ShoppingListRepository repository;

  AddShoppingListItemUseCase(this.repository);

  Future<void> call(ShoppingListItem item) {
    return repository.addItem(item);
  }
}
