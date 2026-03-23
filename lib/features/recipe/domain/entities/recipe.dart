/// Domain entity representing a cooking recipe.
///
/// This entity encapsulates all information about a recipe, including
/// the title, description, list of ingredients, cooking instructions,
/// cooking time, and number of servings.
class Recipe {
  /// The title or name of the recipe
  final String title;

  /// A brief description of the recipe
  final String description;

  /// List of ingredients required for the recipe
  final List<String> ingredients;

  /// Step-by-step cooking instructions
  final List<String> instructions;

  /// Estimated cooking time in minutes
  final int? cookingTime;

  /// Number of servings the recipe yields
  final int? servings;

  /// Creates a [Recipe] instance.
  ///
  /// [title], [description], [ingredients], and [instructions] are required.
  /// [cookingTime] and [servings] are optional.
  const Recipe({
    required this.title,
    required this.description,
    required this.ingredients,
    required this.instructions,
    this.cookingTime,
    this.servings,
  });

  /// Creates a copy of this recipe with the given fields replaced.
  ///
  /// Returns a new [Recipe] instance with updated values for any
  /// non-null parameters, keeping existing values for null parameters.
  Recipe copyWith({
    String? title,
    String? description,
    List<String>? ingredients,
    List<String>? instructions,
    int? cookingTime,
    int? servings,
  }) {
    return Recipe(
      title: title ?? this.title,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      cookingTime: cookingTime ?? this.cookingTime,
      servings: servings ?? this.servings,
    );
  }
}

