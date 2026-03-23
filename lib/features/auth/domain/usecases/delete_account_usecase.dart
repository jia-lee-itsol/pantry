import '../repositories/auth_repository.dart';

// ============================================
// Delete Account Use Case
// ============================================

/// Use case for permanently deleting a user's account.
///
/// This use case encapsulates the business logic for account deletion.
/// This is a destructive operation that cannot be undone.
///
/// Responsibilities:
/// - Execute account deletion
/// - Handle re-authentication requirements
///
/// Note: For security reasons, this operation may require the user to
/// have recently authenticated. If re-authentication is needed, the
/// user should sign out and sign in again before attempting deletion.
///
/// Example:
/// ```dart
/// final useCase = DeleteAccountUseCase(authRepository);
/// try {
///   await useCase();
///   print('Account deleted successfully');
/// } catch (e) {
///   print('Account deletion failed: $e');
/// }
/// ```
class DeleteAccountUseCase {
  /// The authentication repository for performing account deletion
  final AuthRepository repository;

  /// Creates a new DeleteAccountUseCase.
  ///
  /// Parameters:
  /// - [repository]: The authentication repository implementation
  DeleteAccountUseCase(this.repository);

  /// Executes the account deletion operation.
  ///
  /// Permanently deletes the current user's account and all associated data.
  ///
  /// Throws an exception if:
  /// - No user is currently authenticated
  /// - Re-authentication is required
  /// - Account deletion fails
  Future<void> call() {
    return repository.deleteAccount();
  }
}
