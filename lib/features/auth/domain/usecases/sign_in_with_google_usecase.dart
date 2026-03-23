import 'package:flutter/foundation.dart';

import '../entities/user.dart';
import '../repositories/auth_repository.dart';

// ============================================
// Google Sign-In Use Case
// ============================================

/// Use case for handling Google Sign-In authentication.
///
/// This use case encapsulates the business logic for authenticating
/// users via Google OAuth. It coordinates with the repository layer
/// to perform the actual authentication.
///
/// Responsibilities:
/// - Execute Google Sign-In flow
/// - Return authenticated user data
/// - Log authentication steps for debugging
///
/// Example:
/// ```dart
/// final useCase = SignInWithGoogleUseCase(authRepository);
/// try {
///   final user = await useCase();
///   print('Signed in as: ${user.email}');
/// } catch (e) {
///   print('Sign-in failed: $e');
/// }
/// ```
class SignInWithGoogleUseCase {
  /// The authentication repository for performing sign-in operations
  final AuthRepository repository;

  /// Creates a new SignInWithGoogleUseCase.
  ///
  /// Parameters:
  /// - [repository]: The authentication repository implementation
  SignInWithGoogleUseCase(this.repository);

  /// Executes the Google Sign-In flow.
  ///
  /// Returns a [User] object containing the authenticated user's information.
  ///
  /// Throws an exception if authentication fails or is cancelled by the user.
  Future<User> call() {
    debugPrint('[SignInWithGoogleUseCase] call() 호출됨');
    debugPrint('[SignInWithGoogleUseCase] repository.signInWithGoogle() 호출');
    final result = repository.signInWithGoogle();
    debugPrint('[SignInWithGoogleUseCase] repository.signInWithGoogle() 완료');
    return result;
  }
}

