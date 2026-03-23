import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/home/domain/repositories/shopping_list_repository.dart';
import '../../features/home/data/datasources/shopping_list_local_datasource.dart';
import '../../features/home/data/repositories_impl/shopping_list_repository_impl.dart';

/// Shopping List Service Provider
///
/// Provides the shopping list repository implementation using dependency injection.
/// This provider creates and manages the shopping list data source and repository
/// for handling user shopping lists throughout the application.
///
/// The repository manages shopping list items using local storage (SharedPreferences)
/// as the data source for offline-first functionality.
final shoppingListServiceProvider = Provider<ShoppingListRepository>((ref) {
  final dataSource = ShoppingListLocalDataSource();
  return ShoppingListRepositoryImpl(dataSource);
});
