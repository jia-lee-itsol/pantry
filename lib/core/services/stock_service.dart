import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/stock/domain/repositories/stock_repository.dart';
import '../../features/stock/data/datasources/stock_firestore_datasource.dart';
import '../../features/stock/data/repositories_impl/stock_repository_impl.dart';

/// Stock Service Provider
///
/// Provides the stock repository implementation using dependency injection.
/// This provider creates and manages the stock data source and repository
/// for managing pantry/stock items throughout the application.
///
/// The repository handles CRUD operations for stock items using Firestore
/// as the data source.
final stockServiceProvider = Provider<StockRepository>((ref) {
  final dataSource = StockFirestoreDataSource();
  return StockRepositoryImpl(dataSource);
});

