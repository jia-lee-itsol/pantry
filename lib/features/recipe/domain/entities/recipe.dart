/// 레시피 엔티티
class Recipe {
  final String title;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;
  final int? cookingTime; // 분 단위
  final int? servings; // 인분

  const Recipe({
    required this.title,
    required this.description,
    required this.ingredients,
    required this.instructions,
    this.cookingTime,
    this.servings,
  });

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

