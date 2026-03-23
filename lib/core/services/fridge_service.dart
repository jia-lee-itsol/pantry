import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/fridge/domain/repositories/fridge_repository.dart';
import '../../features/fridge/data/datasources/fridge_firestore_datasource.dart';
import '../../features/fridge/data/repositories_impl/fridge_repository_impl.dart';

/// Fridge Service Provider
///
/// Provides the fridge repository implementation using dependency injection.
/// This provider creates and manages the fridge data source and repository
/// for managing refrigerator items throughout the application.
///
/// The repository handles CRUD operations for fridge items using Firestore
/// as the data source.
final fridgeServiceProvider = Provider<FridgeRepository>((ref) {
  final dataSource = FridgeFirestoreDataSource();
  return FridgeRepositoryImpl(dataSource);
});

