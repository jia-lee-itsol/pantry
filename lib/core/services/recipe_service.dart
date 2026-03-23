import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/recipe/domain/repositories/recipe_repository.dart';
import '../../features/recipe/data/datasources/recipe_ai_datasource.dart';
import '../../features/recipe/data/repositories_impl/recipe_repository_impl.dart';

/// Recipe Service Provider
///
/// Provides the recipe repository implementation using dependency injection.
/// This provider creates and manages the recipe data source and repository
/// for handling AI-powered recipe generation throughout the application.
///
/// The repository uses AI (Firebase Gemini) as the data source to generate
/// recipe suggestions based on available ingredients.
final recipeServiceProvider = Provider<RecipeRepository>((ref) {
  final dataSource = RecipeAIDataSource();
  return RecipeRepositoryImpl(dataSource);
});

