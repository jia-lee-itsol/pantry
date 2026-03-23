import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/household/domain/repositories/household_repository.dart';
import '../../features/household/domain/repositories/username_repository.dart';
import '../../features/household/domain/repositories/household_request_repository.dart';
import '../../features/household/data/datasources/household_firestore_datasource.dart';
import '../../features/household/data/datasources/username_firestore_datasource.dart';
import '../../features/household/data/datasources/household_request_firestore_datasource.dart';
import '../../features/household/data/repositories_impl/household_repository_impl.dart';
import '../../features/household/data/repositories_impl/username_repository_impl.dart';
import '../../features/household/data/repositories_impl/household_request_repository_impl.dart';

/// Household Service Provider
///
/// Provides the household repository implementation using dependency injection.
/// This provider creates and manages the household data source and repository
/// for handling household/family group management throughout the application.
///
/// The repository manages household data using Firestore as the data source,
/// enabling multiple users to share and manage items together.
final householdServiceProvider = Provider<HouseholdRepository>((ref) {
  final dataSource = HouseholdFirestoreDataSource();
  return HouseholdRepositoryImpl(dataSource);
});

/// Username Service Provider
///
/// Provides the username repository implementation using dependency injection.
/// This provider creates and manages the username data source and repository
/// for handling user profile names within households.
///
/// The repository manages username data using Firestore as the data source.
final usernameServiceProvider = Provider<UsernameRepository>((ref) {
  final dataSource = UsernameFirestoreDataSource();
  return UsernameRepositoryImpl(dataSource);
});

/// Household Request Service Provider
///
/// Provides the household request repository implementation using dependency injection.
/// This provider creates and manages the household request data source and repository
/// for handling household invitation and join requests.
///
/// The repository manages household join/invite requests using Firestore as the data source.
final householdRequestServiceProvider = Provider<HouseholdRequestRepository>((ref) {
  final dataSource = HouseholdRequestFirestoreDataSource();
  return HouseholdRequestRepositoryImpl(dataSource);
});
