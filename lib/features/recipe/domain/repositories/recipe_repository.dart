import '../entities/recipe.dart';
import '../../../fridge/domain/entities/fridge_item.dart';
import '../../../stock/domain/entities/stock_item.dart';

/// 레시피 추천을 위한 리포지토리 인터페이스
abstract class RecipeRepository {
  /// 현재 재고(냉장고 + 재고)를 기반으로 레시피를 추천합니다.
  ///
  /// [fridgeItems]: 냉장고 재고 목록
  /// [stockItems]: 재고 목록
  /// [count]: 추천받을 레시피 개수 (기본값: 3)
  ///
  /// 반환: 추천 레시피 목록
  Future<List<Recipe>> getRecipeRecommendations({
    required List<FridgeItem> fridgeItems,
    required List<StockItem> stockItems,
    int count = 3,
  });
}

