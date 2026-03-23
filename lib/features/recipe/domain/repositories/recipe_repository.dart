import '../entities/recipe.dart';
import '../../../fridge/domain/entities/fridge_item.dart';
import '../../../stock/domain/entities/stock_item.dart';

/// Repository interface for recipe recommendation operations.
///
/// This repository defines the contract for generating recipe recommendations
/// based on available inventory items from the fridge and stock.
abstract class RecipeRepository {
  /// Generates recipe recommendations based on current inventory.
  ///
  /// Analyzes the available fridge and stock items to suggest recipes
  /// that can be prepared with the available ingredients. Uses AI to
  /// generate creative and practical recipe suggestions.
  ///
  /// Parameters:
  ///   [fridgeItems] - List of items currently in the fridge
  ///   [stockItems] - List of items in stock/pantry
  ///   [count] - Number of recipe recommendations to generate (default: 3)
  ///
  /// Returns a list of [Recipe] objects recommended based on available items.
  /// Throws an exception if recipe generation fails.
  Future<List<Recipe>> getRecipeRecommendations({
    required List<FridgeItem> fridgeItems,
    required List<StockItem> stockItems,
    int count = 3,
  });
}

