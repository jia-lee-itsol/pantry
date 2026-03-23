import '../entities/fridge_item.dart';
import '../repositories/fridge_repository.dart';

/// Use case for updating an existing fridge item.
///
/// This use case encapsulates the business logic for modifying
/// fridge items in the inventory.
///
/// ## Responsibilities:
/// - Validates the updated item (can be extended)
/// - Delegates to the repository to persist changes
/// - Can trigger side effects like audit logs (can be extended)
///
/// ## Usage:
/// ```dart
/// final useCase = UpdateFridgeItemUseCase(repository);
/// final updatedItem = existingItem.copyWith(quantity: 2);
/// await useCase(updatedItem);
/// ```
class UpdateFridgeItemUseCase {
  final FridgeRepository repository;

  UpdateFridgeItemUseCase(this.repository);

  /// Executes the use case to update a fridge item.
  ///
  /// Parameters:
  /// - [item]: The fridge item with updated values
  Future<void> call(FridgeItem item) {
    return repository.updateFridgeItem(item);
  }
}
