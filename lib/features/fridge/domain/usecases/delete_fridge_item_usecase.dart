import '../repositories/fridge_repository.dart';

/// Use case for deleting a fridge item.
///
/// This use case encapsulates the business logic for removing
/// items from the fridge inventory.
///
/// ## Responsibilities:
/// - Validates deletion permission (can be extended)
/// - Delegates to the repository to remove the item
/// - Can trigger side effects like cleanup tasks (can be extended)
///
/// ## Usage:
/// ```dart
/// final useCase = DeleteFridgeItemUseCase(repository);
/// await useCase('item123');
/// ```
class DeleteFridgeItemUseCase {
  final FridgeRepository repository;

  DeleteFridgeItemUseCase(this.repository);

  /// Executes the use case to delete a fridge item.
  ///
  /// Parameters:
  /// - [id]: The ID of the fridge item to delete
  Future<void> call(String id) {
    return repository.deleteFridgeItem(id);
  }
}
