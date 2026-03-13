import '../../domain/entities/recipe.dart';

/// 레시피 데이터 모델
class RecipeModel extends Recipe {
  const RecipeModel({
    required super.title,
    required super.description,
    required super.ingredients,
    required super.instructions,
    super.cookingTime,
    super.servings,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      instructions: (json['instructions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      cookingTime: json['cookingTime'] as int?,
      servings: json['servings'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'ingredients': ingredients,
      'instructions': instructions,
      'cookingTime': cookingTime,
      'servings': servings,
    };
  }

  factory RecipeModel.fromEntity(Recipe entity) {
    return RecipeModel(
      title: entity.title,
      description: entity.description,
      ingredients: entity.ingredients,
      instructions: entity.instructions,
      cookingTime: entity.cookingTime,
      servings: entity.servings,
    );
  }

  Recipe toEntity() {
    return Recipe(
      title: title,
      description: description,
      ingredients: ingredients,
      instructions: instructions,
      cookingTime: cookingTime,
      servings: servings,
    );
  }
}
