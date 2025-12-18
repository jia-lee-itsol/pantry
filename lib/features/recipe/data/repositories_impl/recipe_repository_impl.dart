import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../datasources/recipe_ai_datasource.dart';
import '../../../fridge/domain/entities/fridge_item.dart';
import '../../../stock/domain/entities/stock_item.dart';

/// 레시피 리포지토리 구현
class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeAIDataSource dataSource;

  RecipeRepositoryImpl(this.dataSource);

  @override
  Future<List<Recipe>> getRecipeRecommendations({
    required List<FridgeItem> fridgeItems,
    required List<StockItem> stockItems,
    int count = 3,
  }) async {
    return await dataSource.getRecipeRecommendations(
      fridgeItems: fridgeItems,
      stockItems: stockItems,
      count: count,
    );
  }
}

