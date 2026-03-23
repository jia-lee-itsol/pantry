import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/alert/domain/repositories/alert_repository.dart';
import '../../features/alert/data/datasources/alert_firestore_datasource.dart';
import '../../features/alert/data/repositories_impl/alert_repository_impl.dart';

/// Alert Service Provider
///
/// Provides the alert repository implementation using dependency injection.
/// This provider creates and manages the alert data source and repository
/// for handling user alerts and notifications throughout the application.
///
/// The repository manages alert data using Firestore as the data source.
final alertServiceProvider = Provider<AlertRepository>((ref) {
  final dataSource = AlertFirestoreDataSource();
  return AlertRepositoryImpl(dataSource);
});

