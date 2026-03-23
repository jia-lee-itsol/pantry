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

// ============================================
// Stock Feature Providers
// ============================================
//
// This file defines all Riverpod providers for the stock feature.
// It follows clean architecture principles with dependency injection
// and separation of concerns.
//
// Provider Hierarchy:
// 1. Repository Provider (delegates to core service)
// 2. Use Case Providers (depend on repository)
// 3. Business Logic Providers (standalone use cases)
// 4. Data Providers (expose data to UI layer)
//
// ============================================

// ============================================
// Repository Providers
// ============================================

/// Provides the [StockRepository] implementation.
///
/// This provider delegates to the core [stockServiceProvider] which
/// handles the actual repository implementation and data source configuration.
///
/// **Dependency Injection:**
/// - Consumed by use case providers
/// - Configured at app initialization
/// - Can be overridden for testing
final stockRepositoryProvider = Provider<StockRepository>((ref) {
  return ref.watch(stockServiceProvider);
});

// ============================================
// Use Case Providers - CRUD Operations
// ============================================

/// Provides the [GetStockItemsUseCase] for retrieving stock items.
///
/// **Usage in UI:**
/// ```dart
/// final useCase = ref.read(getStockItemsUseCaseProvider);
/// final items = await useCase();
/// ```
final getStockItemsUseCaseProvider = Provider<GetStockItemsUseCase>((ref) {
  final repository = ref.watch(stockRepositoryProvider);
  return GetStockItemsUseCase(repository);
});

/// Provides the [AddStockItemUseCase] for adding new stock items.
///
/// **Usage in UI:**
/// ```dart
/// final useCase = ref.read(addStockItemUseCaseProvider);
/// await useCase(newItem);
/// ```
final addStockItemUseCaseProvider = Provider<AddStockItemUseCase>((ref) {
  final repository = ref.watch(stockRepositoryProvider);
  return AddStockItemUseCase(repository);
});

/// Provides the [UpdateStockItemUseCase] for updating existing stock items.
///
/// **Usage in UI:**
/// ```dart
/// final useCase = ref.read(updateStockItemUseCaseProvider);
/// await useCase(updatedItem);
/// ```
final updateStockItemUseCaseProvider = Provider<UpdateStockItemUseCase>((ref) {
  final repository = ref.watch(stockRepositoryProvider);
  return UpdateStockItemUseCase(repository);
});

/// Provides the [DeleteStockItemUseCase] for removing stock items.
///
/// **Usage in UI:**
/// ```dart
/// final useCase = ref.read(deleteStockItemUseCaseProvider);
/// await useCase(itemId);
/// ```
final deleteStockItemUseCaseProvider = Provider<DeleteStockItemUseCase>((ref) {
  final repository = ref.watch(stockRepositoryProvider);
  return DeleteStockItemUseCase(repository);
});

// ============================================
// Use Case Providers - Business Logic
// ============================================

/// Provides the [GuessCategoryUseCase] for automatic category detection.
///
/// This is a standalone use case that doesn't depend on the repository.
///
/// **Usage in UI:**
/// ```dart
/// final useCase = ref.read(guessCategoryUseCaseProvider);
/// final category = useCase('Bottled Water');
/// ```
final guessCategoryUseCaseProvider = Provider<GuessCategoryUseCase>((ref) {
  return GuessCategoryUseCase();
});

/// Provides the [GroupStockItemsUseCase] for organizing items by category.
///
/// **Dependencies:**
/// - [guessCategoryUseCaseProvider] for automatic categorization
///
/// **Usage in UI:**
/// ```dart
/// final useCase = ref.read(groupStockItemsUseCaseProvider);
/// final grouped = useCase(allItems);
/// ```
final groupStockItemsUseCaseProvider = Provider<GroupStockItemsUseCase>((ref) {
  final guessCategoryUseCase = ref.watch(guessCategoryUseCaseProvider);
  return GroupStockItemsUseCase(guessCategoryUseCase);
});

// ============================================
// Data Providers
// ============================================

/// Provides the list of all stock items as a [FutureProvider].
///
/// This provider automatically fetches stock items when first accessed
/// and handles loading/error states through Riverpod's state management.
///
/// **State Management:**
/// - Loading: `AsyncValue.loading()`
/// - Success: `AsyncValue.data(List)`
/// - Error: `AsyncValue.error(error, stackTrace)`
///
/// **Usage in UI:**
/// ```dart
/// final stockItemsAsync = ref.watch(stockItemsProvider);
/// stockItemsAsync.when(
///   data: (items) => ListView(...),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => ErrorWidget(err),
/// );
/// ```
///
/// **Refresh:**
/// ```dart
/// ref.refresh(stockItemsProvider); // Triggers a new fetch
/// ```
final stockItemsProvider = FutureProvider<List<StockItem>>((ref) async {
  final useCase = ref.watch(getStockItemsUseCaseProvider);
  return useCase();
});
