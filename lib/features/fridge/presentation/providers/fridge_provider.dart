import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/fridge_item.dart';
import '../../domain/repositories/fridge_repository.dart';
import '../../../../core/services/fridge_service.dart';

// 실제 데이터 소스 사용
final fridgeRepositoryProvider = Provider<FridgeRepository>((ref) {
  return ref.watch(fridgeServiceProvider);
});

final fridgeItemsProvider = FutureProvider<List<FridgeItem>>((ref) async {
  final repository = ref.watch(fridgeRepositoryProvider);
  return repository.getFridgeItems();
});
