import '../repositories/fridge_repository.dart';

class DeleteFridgeItemUseCase {
  final FridgeRepository repository;

  DeleteFridgeItemUseCase(this.repository);

  Future<void> call(String id) {
    return repository.deleteFridgeItem(id);
  }
}
