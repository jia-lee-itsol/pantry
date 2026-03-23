import 'package:flutter/foundation.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_firebase_datasource.dart';

// ============================================
// Authentication Repository Implementation
// ============================================

/// Implementation of the authentication repository using Firebase.
///
/// This class implements the [AuthRepository] interface and delegates
/// all authentication operations to the Firebase data source.
///
/// Responsibilities:
/// - Implement authentication repository contract
/// - Delegate operations to Firebase data source
/// - Provide logging for debugging
///
/// Example:
/// ```dart
/// final dataSource = AuthFirebaseDataSource();
/// final repository = AuthRepositoryImpl(dataSource);
/// final user = await repository.signInWithGoogle();
/// ```
class AuthRepositoryImpl implements AuthRepository {
  /// The Firebase data source for authentication operations
  final AuthFirebaseDataSource dataSource;

  /// Creates a new AuthRepositoryImpl.
  ///
  /// Parameters:
  /// - [dataSource]: The Firebase data source for authentication
  AuthRepositoryImpl(this.dataSource);

  /// Gets the currently authenticated user.
  ///
  /// Returns a [User] object if authenticated, null otherwise.
  @override
  Future<User?> getCurrentUser() async {
    return dataSource.getCurrentUser();
  }

  /// Performs Google Sign-In authentication.
  ///
  /// Returns a [User] object with authentication details.
  /// Logs the authentication process for debugging.
  @override
  Future<User> signInWithGoogle() async {
    debugPrint('[AuthRepositoryImpl] signInWithGoogle() 호출됨');
    debugPrint('[AuthRepositoryImpl] dataSource.signInWithGoogle() 호출');
    final result = await dataSource.signInWithGoogle();
    debugPrint('[AuthRepositoryImpl] dataSource.signInWithGoogle() 완료');
    return result;
  }

  /// Performs Apple Sign-In authentication.
  ///
  /// Returns a [User] object with authentication details.
  @override
  Future<User> signInWithApple() async {
    return await dataSource.signInWithApple();
  }

  /// Signs out the current user from all providers.
  @override
  Future<void> signOut() async {
    await dataSource.signOut();
  }

  /// Permanently deletes the current user's account.
  @override
  Future<void> deleteAccount() async {
    await dataSource.deleteAccount();
  }

  /// Returns a stream of authentication state changes.
  ///
  /// Emits a [User] when signed in, null when signed out.
  @override
  Stream<User?> authStateChanges() {
    return dataSource.authStateChanges();
  }
}

