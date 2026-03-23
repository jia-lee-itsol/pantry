import '../entities/user.dart';
import '../repositories/auth_repository.dart';

// ============================================
// Get Current User Use Case
// ============================================

/// Use case for retrieving the currently authenticated user.
///
/// This use case encapsulates the business logic for fetching the
/// current user's information from the authentication system.
///
/// Responsibilities:
/// - Retrieve current user data
/// - Return null if no user is authenticated
///
/// Example:
/// ```dart
/// final useCase = GetCurrentUserUseCase(authRepository);
/// final user = await useCase();
/// if (user != null) {
///   print('Current user: ${user.email}');
/// } else {
///   print('No user is signed in');
/// }
/// ```
class GetCurrentUserUseCase {
  /// The authentication repository for retrieving user information
  final AuthRepository repository;

  /// Creates a new GetCurrentUserUseCase.
  ///
  /// Parameters:
  /// - [repository]: The authentication repository implementation
  GetCurrentUserUseCase(this.repository);

  /// Retrieves the currently authenticated user.
  ///
  /// Returns:
  /// - A [User] object if a user is currently authenticated
  /// - null if no user is authenticated
  Future<User?> call() {
    return repository.getCurrentUser();
  }
}

