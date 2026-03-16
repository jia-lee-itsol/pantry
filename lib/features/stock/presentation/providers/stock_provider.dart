import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/stock_item.dart';
import '../../domain/repositories/stock_repository.dart';
import '../../domain/usecases/get_stock_items_usecase.dart';
import '../../domain/usecases/add_stock_item_usecase.dart';
import '../../domain/usecases/update_stock_item_usecase.dart';
import '../../domain/usecases/delete_stock_item_usecase.dart';
import '../../domain/usecases/guess_category_usecase.dart';
import '../../domain/usecases/group_stock_items_usecase.dart';
import '../../../../core/services/stock_service.dart';

// Repository Provider (uses core service)
final stockRepositoryProvider = Provider<StockRepository>((ref) {
  return ref.watch(stockServiceProvider);
});

// UseCase Providers
final getStockItemsUseCaseProvider = Provider<GetStockItemsUseCase>((ref) {
  final repository = ref.watch(stockRepositoryProvider);
  return GetStockItemsUseCase(repository);
});

final addStockItemUseCaseProvider = Provider<AddStockItemUseCase>((ref) {
  final repository = ref.watch(stockRepositoryProvider);
  return AddStockItemUseCase(repository);
});

final updateStockItemUseCaseProvider = Provider<UpdateStockItemUseCase>((ref) {
  final repository = ref.watch(stockRepositoryProvider);
  return UpdateStockItemUseCase(repository);
});

final deleteStockItemUseCaseProvider = Provider<DeleteStockItemUseCase>((ref) {
  final repository = ref.watch(stockRepositoryProvider);
  return DeleteStockItemUseCase(repository);
});

// Business Logic Use Case Providers
final guessCategoryUseCaseProvider = Provider<GuessCategoryUseCase>((ref) {
  return GuessCategoryUseCase();
});

final groupStockItemsUseCaseProvider = Provider<GroupStockItemsUseCase>((ref) {
  final guessCategoryUseCase = ref.watch(guessCategoryUseCaseProvider);
  return GroupStockItemsUseCase(guessCategoryUseCase);
});

// Stock Items Provider (uses GetStockItemsUseCase)
final stockItemsProvider = FutureProvider<List<StockItem>>((ref) async {
  final useCase = ref.watch(getStockItemsUseCaseProvider);
  return useCase();
});
