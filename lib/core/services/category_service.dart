import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/domain/repositories/category_repository.dart';
import '../../features/settings/data/datasources/category_local_datasource.dart';
import '../../features/settings/data/repositories_impl/category_repository_impl.dart';

/// Category Service Provider
///
/// Provides the category repository implementation using dependency injection.
/// This provider creates and manages the category data source and repository
/// for handling item categories throughout the application.
///
/// The repository manages custom categories using local storage (SharedPreferences)
/// as the data source, allowing users to organize their items with custom categories.
final categoryServiceProvider = Provider<CategoryRepository>((ref) {
  final dataSource = CategoryLocalDataSource();
  return CategoryRepositoryImpl(dataSource);
});
