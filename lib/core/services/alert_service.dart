import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/alert/domain/repositories/alert_repository.dart';
import '../../features/alert/data/datasources/alert_firestore_datasource.dart';
import '../../features/alert/data/repositories_impl/alert_repository_impl.dart';

final alertServiceProvider = Provider<AlertRepository>((ref) {
  final dataSource = AlertFirestoreDataSource();
  return AlertRepositoryImpl(dataSource);
});

