import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/home/domain/repositories/shopping_list_repository.dart';
import '../../features/home/data/datasources/shopping_list_local_datasource.dart';
import '../../features/home/data/repositories_impl/shopping_list_repository_impl.dart';

/// 쇼핑 리스트 서비스 프로바이더
final shoppingListServiceProvider = Provider<ShoppingListRepository>((ref) {
  final dataSource = ShoppingListLocalDataSource();
  return ShoppingListRepositoryImpl(dataSource);
});
