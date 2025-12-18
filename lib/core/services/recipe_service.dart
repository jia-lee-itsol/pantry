import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/recipe/domain/repositories/recipe_repository.dart';
import '../../features/recipe/data/datasources/recipe_ai_datasource.dart';
import '../../features/recipe/data/repositories_impl/recipe_repository_impl.dart';

/// 레시피 서비스 프로바이더
final recipeServiceProvider = Provider<RecipeRepository>((ref) {
  final dataSource = RecipeAIDataSource();
  return RecipeRepositoryImpl(dataSource);
});

