import '../repositories/shopping_list_repository.dart';

class DeleteShoppingListItemUseCase {
  final ShoppingListRepository repository;

  DeleteShoppingListItemUseCase(this.repository);

  Future<void> call(String id) {
    return repository.deleteItem(id);
  }
}
