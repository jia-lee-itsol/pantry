import '../entities/fridge_item.dart';
import '../repositories/fridge_repository.dart';

/// Use case for retrieving all fridge items.
///
/// This use case encapsulates the business logic for fetching
/// fridge items from the repository.
///
/// ## Responsibilities:
/// - Delegates to the repository to fetch items
/// - Can be extended to add filtering or sorting logic
/// - Provides a clear entry point for this specific operation
///
/// ## Usage:
/// ```dart
/// final useCase = GetFridgeItemsUseCase(repository);
/// final items = await useCase();
/// ```
class GetFridgeItemsUseCase {
  final FridgeRepository repository;

  GetFridgeItemsUseCase(this.repository);

  /// Executes the use case to retrieve all fridge items.
  ///
  /// Returns a list of [FridgeItem] entities.
  Future<List<FridgeItem>> call() {
    return repository.getFridgeItems();
  }
}
