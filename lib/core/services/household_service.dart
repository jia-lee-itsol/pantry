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

/// Household 서비스 프로바이더
final householdServiceProvider = Provider<HouseholdRepository>((ref) {
  final dataSource = HouseholdFirestoreDataSource();
  return HouseholdRepositoryImpl(dataSource);
});

/// Username 서비스 프로바이더
final usernameServiceProvider = Provider<UsernameRepository>((ref) {
  final dataSource = UsernameFirestoreDataSource();
  return UsernameRepositoryImpl(dataSource);
});

/// Household Request 서비스 프로바이더
final householdRequestServiceProvider = Provider<HouseholdRequestRepository>((ref) {
  final dataSource = HouseholdRequestFirestoreDataSource();
  return HouseholdRequestRepositoryImpl(dataSource);
});
