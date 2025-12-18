import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/stock_item.dart';
import '../../domain/repositories/stock_repository.dart';
import '../../../../core/services/stock_service.dart';

// 실제 데이터 소스 사용
final stockRepositoryProvider = Provider<StockRepository>((ref) {
  return ref.watch(stockServiceProvider);
});

final stockItemsProvider = FutureProvider<List<StockItem>>((ref) async {
  final repository = ref.watch(stockRepositoryProvider);
  return repository.getStockItems();
});

