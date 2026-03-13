import '../entities/fridge_item.dart';
import '../repositories/fridge_repository.dart';

class AddFridgeItemUseCase {
  final FridgeRepository repository;

  AddFridgeItemUseCase(this.repository);

  Future<void> call(FridgeItem item) {
    return repository.addFridgeItem(item);
  }
}
