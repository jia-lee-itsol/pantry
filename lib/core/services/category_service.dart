import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/domain/repositories/category_repository.dart';
import '../../features/settings/data/datasources/category_local_datasource.dart';
import '../../features/settings/data/repositories_impl/category_repository_impl.dart';

/// 카테고리 서비스 프로바이더
final categoryServiceProvider = Provider<CategoryRepository>((ref) {
  final dataSource = CategoryLocalDataSource();
  return CategoryRepositoryImpl(dataSource);
});
