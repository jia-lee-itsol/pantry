import '../entities/user.dart';

// ============================================
// Authentication Repository Interface
// ============================================

/// Repository interface for authentication operations.
///
/// This abstract class defines the contract for authentication-related
/// operations in the domain layer. Implementations should handle the
/// actual authentication logic with external services.
///
/// Responsibilities:
/// - Define authentication operation contracts
/// - Provide type-safe method signatures
/// - Enable dependency injection and testing
///
/// Example implementation usage:
/// ```dart
/// class MyAuthRepository implements AuthRepository {
///   @override
///   Future<User> signInWithGoogle() async {
///     // Implementation here
///   }
///   // ... other methods
/// }
/// ```
abstract class AuthRepository {
  /// Gets the currently logged-in user information.
  ///
  /// Returns:
  /// - A [User] object if a user is currently authenticated
  /// - null if no user is authenticated
  Future<User?> getCurrentUser();

  /// Performs Google Sign-In authentication.
  ///
  /// Returns a [User] object containing the authenticated user's information.
  ///
  /// Throws an exception if authentication fails or is cancelled.
  Future<User> signInWithGoogle();

  /// Performs Apple Sign-In authentication.
  ///
  /// Returns a [User] object containing the authenticated user's information.
  ///
  /// Throws an exception if authentication fails or is cancelled.
  ///
  /// Note: Only supported on iOS and macOS platforms.
  Future<User> signInWithApple();

  /// Signs out the current user.
  ///
  /// Clears all authentication state and signs out from all providers.
  ///
  /// Throws an exception if sign-out fails.
  Future<void> signOut();

  /// Permanently deletes the current user's account.
  ///
  /// This operation cannot be undone. The user will need to create a new
  /// account to use the app again.
  ///
  /// Throws an exception if:
  /// - No user is currently authenticated
  /// - Re-authentication is required for security
  /// - Account deletion fails
  Future<void> deleteAccount();

  /// Returns a stream of authentication state changes.
  ///
  /// The stream emits:
  /// - A [User] object when a user signs in or authentication state changes
  /// - null when a user signs out
  ///
  /// This stream is useful for reacting to authentication changes in real-time.
  Stream<User?> authStateChanges();
}

