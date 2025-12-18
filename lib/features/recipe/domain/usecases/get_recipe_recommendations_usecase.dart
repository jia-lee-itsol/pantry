import '../entities/recipe.dart';
import '../repositories/recipe_repository.dart';
import '../../../fridge/domain/entities/fridge_item.dart';
import '../../../stock/domain/entities/stock_item.dart';

/// 레시피 추천 유스케이스
class GetRecipeRecommendationsUseCase {
  final RecipeRepository repository;

  GetRecipeRecommendationsUseCase(this.repository);

  /// 현재 재고를 기반으로 레시피를 추천합니다.
  ///
  /// [fridgeItems]: 냉장고 재고 목록
  /// [stockItems]: 재고 목록
  /// [count]: 추천받을 레시피 개수 (기본값: 3)
  ///
  /// 반환: 추천 레시피 목록
  Future<List<Recipe>> call({
    required List<FridgeItem> fridgeItems,
    required List<StockItem> stockItems,
    int count = 3,
  }) {
    return repository.getRecipeRecommendations(
      fridgeItems: fridgeItems,
      stockItems: stockItems,
      count: count,
    );
  }
}

