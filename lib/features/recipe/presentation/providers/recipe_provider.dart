import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../../domain/usecases/get_recipe_recommendations_usecase.dart';
import '../../../../core/services/recipe_service.dart';
import '../../../fridge/presentation/providers/fridge_provider.dart';
import '../../../fridge/domain/entities/fridge_item.dart';
import '../../../stock/presentation/providers/stock_provider.dart';
import '../../../stock/domain/entities/stock_item.dart';

/// Provider for the recipe repository.
///
/// Exposes the [RecipeRepository] interface, implemented by the core
/// recipe service. Enables dependency injection for recipe operations.
final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  return ref.watch(recipeServiceProvider);
});

/// Provider for the get recipe recommendations use case.
///
/// Creates an instance of [GetRecipeRecommendationsUseCase] with the
/// injected recipe repository, following clean architecture principles.
final getRecipeRecommendationsUseCaseProvider =
    Provider<GetRecipeRecommendationsUseCase>((ref) {
  final repository = ref.watch(recipeRepositoryProvider);
  return GetRecipeRecommendationsUseCase(repository);
});

/// Provider for recipe recommendations based on current inventory.
///
/// An auto-dispose provider that generates recipe recommendations by
/// analyzing items in the fridge and stock. Automatically fetches the
/// latest inventory data and requests AI-generated recipes that can
/// be made with available ingredients.
///
/// Returns a list of [Recipe] objects, or an empty list if no inventory
/// is available or recipe generation fails.
final recipeRecommendationsProvider =
    FutureProvider.autoDispose<List<Recipe>>((ref) async {
  final useCase = ref.watch(getRecipeRecommendationsUseCaseProvider);
  final fridgeItemsAsync = ref.watch(fridgeItemsProvider);
  final stockItemsAsync = ref.watch(stockItemsProvider);

  // Wait for inventory data to be ready
  // FutureProvider automatically manages loading state,
  // so we wait here until data is available
  List<FridgeItem> fridgeItems;
  List<StockItem> stockItems;

  if (fridgeItemsAsync.isLoading) {
    // If loading, wait for data to be ready
    fridgeItems = await fridgeItemsAsync.when(
      data: (items) => Future.value(items),
      loading: () async {
        // Wait for FutureProvider to complete
        await Future.delayed(const Duration(milliseconds: 100));
        return fridgeItemsAsync.value ?? <FridgeItem>[];
      },
      error: (_, __) => Future.value(<FridgeItem>[]),
    );
  } else {
    fridgeItems = fridgeItemsAsync.value ?? <FridgeItem>[];
  }

  if (stockItemsAsync.isLoading) {
    // If loading, wait for data to be ready
    stockItems = await stockItemsAsync.when(
      data: (items) => Future.value(items),
      loading: () async {
        // Wait for FutureProvider to complete
        await Future.delayed(const Duration(milliseconds: 100));
        return stockItemsAsync.value ?? <StockItem>[];
      },
      error: (_, __) => Future.value(<StockItem>[]),
    );
  } else {
    stockItems = stockItemsAsync.value ?? <StockItem>[];
  }

  // Return empty list if no inventory is available
  if (fridgeItems.isEmpty && stockItems.isEmpty) {
    return [];
  }

  // Request recipe recommendations
  return await useCase.call(
    fridgeItems: fridgeItems,
    stockItems: stockItems,
    count: 3,
  );
});

