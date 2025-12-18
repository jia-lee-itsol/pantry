import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/fridge/domain/repositories/fridge_repository.dart';
import '../../features/fridge/data/datasources/fridge_firestore_datasource.dart';
import '../../features/fridge/data/repositories_impl/fridge_repository_impl.dart';

final fridgeServiceProvider = Provider<FridgeRepository>((ref) {
  final dataSource = FridgeFirestoreDataSource();
  return FridgeRepositoryImpl(dataSource);
});

