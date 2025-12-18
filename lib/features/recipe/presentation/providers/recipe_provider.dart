import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../../domain/usecases/get_recipe_recommendations_usecase.dart';
import '../../../../core/services/recipe_service.dart';
import '../../../fridge/presentation/providers/fridge_provider.dart';
import '../../../fridge/domain/entities/fridge_item.dart';
import '../../../stock/presentation/providers/stock_provider.dart';
import '../../../stock/domain/entities/stock_item.dart';

/// 레시피 리포지토리 프로바이더
final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  return ref.watch(recipeServiceProvider);
});

/// 레시피 추천 유스케이스 프로바이더
final getRecipeRecommendationsUseCaseProvider =
    Provider<GetRecipeRecommendationsUseCase>((ref) {
  final repository = ref.watch(recipeRepositoryProvider);
  return GetRecipeRecommendationsUseCase(repository);
});

/// 레시피 추천 프로바이더
/// 현재 재고(냉장고 + 재고)를 기반으로 레시피를 추천합니다.
final recipeRecommendationsProvider =
    FutureProvider.autoDispose<List<Recipe>>((ref) async {
  final useCase = ref.watch(getRecipeRecommendationsUseCaseProvider);
  final fridgeItemsAsync = ref.watch(fridgeItemsProvider);
  final stockItemsAsync = ref.watch(stockItemsProvider);

  // 재고 데이터가 로딩 중이면 대기
  // FutureProvider는 자동으로 로딩 상태를 관리하므로
  // 여기서는 데이터가 준비될 때까지 기다림
  List<FridgeItem> fridgeItems;
  List<StockItem> stockItems;

  if (fridgeItemsAsync.isLoading) {
    // 로딩 중이면 데이터가 준비될 때까지 대기
    fridgeItems = await fridgeItemsAsync.when(
      data: (items) => Future.value(items),
      loading: () async {
        // FutureProvider가 완료될 때까지 대기
        await Future.delayed(const Duration(milliseconds: 100));
        return fridgeItemsAsync.value ?? <FridgeItem>[];
      },
      error: (_, __) => Future.value(<FridgeItem>[]),
    );
  } else {
    fridgeItems = fridgeItemsAsync.value ?? <FridgeItem>[];
  }

  if (stockItemsAsync.isLoading) {
    // 로딩 중이면 데이터가 준비될 때까지 대기
    stockItems = await stockItemsAsync.when(
      data: (items) => Future.value(items),
      loading: () async {
        // FutureProvider가 완료될 때까지 대기
        await Future.delayed(const Duration(milliseconds: 100));
        return stockItemsAsync.value ?? <StockItem>[];
      },
      error: (_, __) => Future.value(<StockItem>[]),
    );
  } else {
    stockItems = stockItemsAsync.value ?? <StockItem>[];
  }

  // 재고가 없으면 빈 리스트 반환
  if (fridgeItems.isEmpty && stockItems.isEmpty) {
    return [];
  }

  // 레시피 추천 요청
  return await useCase.call(
    fridgeItems: fridgeItems,
    stockItems: stockItems,
    count: 3,
  );
});

