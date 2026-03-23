import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/data/datasources/auth_firebase_datasource.dart';
import '../../features/auth/data/repositories_impl/auth_repository_impl.dart';

/// Authentication Service Provider
///
/// Provides the authentication repository implementation using dependency injection.
/// This provider creates and manages the authentication data source and repository
/// for handling user authentication throughout the application.
///
/// The repository manages user authentication using Firebase Authentication
/// as the data source, supporting sign-in, sign-up, and sign-out operations.
final authServiceProvider = Provider<AuthRepository>((ref) {
  final dataSource = AuthFirebaseDataSource();
  return AuthRepositoryImpl(dataSource);
});

