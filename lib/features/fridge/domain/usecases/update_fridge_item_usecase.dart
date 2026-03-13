import '../entities/fridge_item.dart';
import '../repositories/fridge_repository.dart';

class UpdateFridgeItemUseCase {
  final FridgeRepository repository;

  UpdateFridgeItemUseCase(this.repository);

  Future<void> call(FridgeItem item) {
    return repository.updateFridgeItem(item);
  }
}
