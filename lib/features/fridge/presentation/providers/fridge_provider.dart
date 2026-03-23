import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/fridge_item.dart';
import '../../domain/repositories/fridge_repository.dart';
import '../../domain/usecases/get_fridge_items_usecase.dart';
import '../../domain/usecases/add_fridge_item_usecase.dart';
import '../../domain/usecases/update_fridge_item_usecase.dart';
import '../../domain/usecases/delete_fridge_item_usecase.dart';
import '../../domain/usecases/group_fridge_items_usecase.dart';
import '../../domain/usecases/get_near_expiry_items_usecase.dart';
import '../../../../core/services/fridge_service.dart';

// ============================================
// Repository Provider
// ============================================

/// Provider for the fridge repository.
///
/// Uses the core [fridgeServiceProvider] which implements [FridgeRepository].
/// This enables dependency injection and makes the repository accessible
/// throughout the widget tree.
final fridgeRepositoryProvider = Provider<FridgeRepository>((ref) {
  return ref.watch(fridgeServiceProvider);
});

// ============================================
// Use Case Providers - Data Operations
// ============================================

/// Provider for the get fridge items use case.
///
/// Provides access to the [GetFridgeItemsUseCase] for retrieving
/// all fridge items from the repository.
final getFridgeItemsUseCaseProvider = Provider<GetFridgeItemsUseCase>((ref) {
  final repository = ref.watch(fridgeRepositoryProvider);
  return GetFridgeItemsUseCase(repository);
});

/// Provider for the add fridge item use case.
///
/// Provides access to the [AddFridgeItemUseCase] for creating
/// new fridge items in the repository.
final addFridgeItemUseCaseProvider = Provider<AddFridgeItemUseCase>((ref) {
  final repository = ref.watch(fridgeRepositoryProvider);
  return AddFridgeItemUseCase(repository);
});

/// Provider for the update fridge item use case.
///
/// Provides access to the [UpdateFridgeItemUseCase] for modifying
/// existing fridge items in the repository.
final updateFridgeItemUseCaseProvider = Provider<UpdateFridgeItemUseCase>((ref) {
  final repository = ref.watch(fridgeRepositoryProvider);
  return UpdateFridgeItemUseCase(repository);
});

/// Provider for the delete fridge item use case.
///
/// Provides access to the [DeleteFridgeItemUseCase] for removing
/// fridge items from the repository.
final deleteFridgeItemUseCaseProvider = Provider<DeleteFridgeItemUseCase>((ref) {
  final repository = ref.watch(fridgeRepositoryProvider);
  return DeleteFridgeItemUseCase(repository);
});

// ============================================
// Use Case Providers - Business Logic
// ============================================

/// Provider for the group fridge items use case.
///
/// Provides access to the [GroupFridgeItemsUseCase] for organizing
/// items by category and applying sorting.
///
/// This is a stateless use case that doesn't depend on a repository.
final groupFridgeItemsUseCaseProvider = Provider<GroupFridgeItemsUseCase>((ref) {
  return GroupFridgeItemsUseCase();
});

/// Provider for the get near expiry items use case.
///
/// Provides access to the [GetNearExpiryItemsUseCase] for filtering
/// items that are approaching their expiration date.
///
/// This is a stateless use case that doesn't depend on a repository.
final getNearExpiryItemsUseCaseProvider = Provider<GetNearExpiryItemsUseCase>((ref) {
  return GetNearExpiryItemsUseCase();
});

// ============================================
// Data Providers
// ============================================

/// Provider for fridge items data.
///
/// This [FutureProvider] fetches and caches the list of all fridge items
/// using the [GetFridgeItemsUseCase].
///
/// ## Features:
/// - Automatic loading state management
/// - Error handling built-in
/// - Caching (won't refetch unless invalidated)
///
/// ## Usage:
/// ```dart
/// // In a ConsumerWidget
/// final itemsAsync = ref.watch(fridgeItemsProvider);
/// itemsAsync.when(
///   data: (items) => ListView(children: items.map(buildItem).toList()),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error: $err'),
/// );
///
/// // To refresh the data
/// ref.invalidate(fridgeItemsProvider);
/// ```
final fridgeItemsProvider = FutureProvider<List<FridgeItem>>((ref) async {
  final useCase = ref.watch(getFridgeItemsUseCaseProvider);
  return useCase();
});
