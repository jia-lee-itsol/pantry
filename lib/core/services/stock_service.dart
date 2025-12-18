import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/stock/domain/repositories/stock_repository.dart';
import '../../features/stock/data/datasources/stock_firestore_datasource.dart';
import '../../features/stock/data/repositories_impl/stock_repository_impl.dart';

final stockServiceProvider = Provider<StockRepository>((ref) {
  final dataSource = StockFirestoreDataSource();
  return StockRepositoryImpl(dataSource);
});

