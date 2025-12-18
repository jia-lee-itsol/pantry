import '../entities/fridge_item.dart';
import '../repositories/fridge_repository.dart';

class GetFridgeItemsUseCase {
  final FridgeRepository repository;

  GetFridgeItemsUseCase(this.repository);

  Future<List<FridgeItem>> call() {
    return repository.getFridgeItems();
  }
}
