import '../entities/fridge_item.dart';
import '../repositories/fridge_repository.dart';

/// Use case for adding a new fridge item.
///
/// This use case encapsulates the business logic for adding
/// items to the fridge inventory.
///
/// ## Responsibilities:
/// - Validates the item before adding (can be extended)
/// - Delegates to the repository to persist the item
/// - Can trigger side effects like notifications (can be extended)
///
/// ## Usage:
/// ```dart
/// final useCase = AddFridgeItemUseCase(repository);
/// final newItem = FridgeItem(
///   id: uuid.v4(),
///   name: 'Milk',
///   quantity: 1,
///   expiryDate: DateTime.now().add(Duration(days: 7)),
///   createdAt: DateTime.now(),
/// );
/// await useCase(newItem);
/// ```
class AddFridgeItemUseCase {
  final FridgeRepository repository;

  AddFridgeItemUseCase(this.repository);

  /// Executes the use case to add a fridge item.
  ///
  /// Parameters:
  /// - [item]: The fridge item to add
  Future<void> call(FridgeItem item) {
    return repository.addFridgeItem(item);
  }
}
