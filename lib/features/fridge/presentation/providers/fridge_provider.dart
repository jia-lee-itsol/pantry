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

// Repository Provider (uses core service)
final fridgeRepositoryProvider = Provider<FridgeRepository>((ref) {
  return ref.watch(fridgeServiceProvider);
});

// UseCase Providers
final getFridgeItemsUseCaseProvider = Provider<GetFridgeItemsUseCase>((ref) {
  final repository = ref.watch(fridgeRepositoryProvider);
  return GetFridgeItemsUseCase(repository);
});

final addFridgeItemUseCaseProvider = Provider<AddFridgeItemUseCase>((ref) {
  final repository = ref.watch(fridgeRepositoryProvider);
  return AddFridgeItemUseCase(repository);
});

final updateFridgeItemUseCaseProvider = Provider<UpdateFridgeItemUseCase>((ref) {
  final repository = ref.watch(fridgeRepositoryProvider);
  return UpdateFridgeItemUseCase(repository);
});

final deleteFridgeItemUseCaseProvider = Provider<DeleteFridgeItemUseCase>((ref) {
  final repository = ref.watch(fridgeRepositoryProvider);
  return DeleteFridgeItemUseCase(repository);
});

// Business Logic Use Case Providers
final groupFridgeItemsUseCaseProvider = Provider<GroupFridgeItemsUseCase>((ref) {
  return GroupFridgeItemsUseCase();
});

final getNearExpiryItemsUseCaseProvider = Provider<GetNearExpiryItemsUseCase>((ref) {
  return GetNearExpiryItemsUseCase();
});

// Fridge Items Provider (uses GetFridgeItemsUseCase)
final fridgeItemsProvider = FutureProvider<List<FridgeItem>>((ref) async {
  final useCase = ref.watch(getFridgeItemsUseCaseProvider);
  return useCase();
});
