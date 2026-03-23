import '../repositories/auth_repository.dart';

// ============================================
// Sign Out Use Case
// ============================================

/// Use case for signing out the current user.
///
/// This use case encapsulates the business logic for signing out
/// a user from the authentication system. It ensures proper cleanup
/// of authentication state across all providers.
///
/// Responsibilities:
/// - Execute sign-out operation
/// - Clear authentication state
///
/// Example:
/// ```dart
/// final useCase = SignOutUseCase(authRepository);
/// try {
///   await useCase();
///   print('Signed out successfully');
/// } catch (e) {
///   print('Sign-out failed: $e');
/// }
/// ```
class SignOutUseCase {
  /// The authentication repository for performing sign-out operations
  final AuthRepository repository;

  /// Creates a new SignOutUseCase.
  ///
  /// Parameters:
  /// - [repository]: The authentication repository implementation
  SignOutUseCase(this.repository);

  /// Executes the sign-out operation.
  ///
  /// Clears all authentication state and signs out from all providers.
  ///
  /// Throws an exception if the sign-out operation fails.
  Future<void> call() {
    return repository.signOut();
  }
}

