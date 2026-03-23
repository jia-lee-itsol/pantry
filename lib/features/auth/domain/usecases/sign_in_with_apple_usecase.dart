import '../entities/user.dart';
import '../repositories/auth_repository.dart';

// ============================================
// Apple Sign-In Use Case
// ============================================

/// Use case for handling Apple Sign-In authentication.
///
/// This use case encapsulates the business logic for authenticating
/// users via Apple OAuth. It coordinates with the repository layer
/// to perform the actual authentication.
///
/// Note: Apple Sign-In is only available on iOS and macOS platforms.
///
/// Responsibilities:
/// - Execute Apple Sign-In flow
/// - Return authenticated user data
///
/// Example:
/// ```dart
/// final useCase = SignInWithAppleUseCase(authRepository);
/// try {
///   final user = await useCase();
///   print('Signed in as: ${user.email}');
/// } catch (e) {
///   print('Sign-in failed: $e');
/// }
/// ```
class SignInWithAppleUseCase {
  /// The authentication repository for performing sign-in operations
  final AuthRepository repository;

  /// Creates a new SignInWithAppleUseCase.
  ///
  /// Parameters:
  /// - [repository]: The authentication repository implementation
  SignInWithAppleUseCase(this.repository);

  /// Executes the Apple Sign-In flow.
  ///
  /// Returns a [User] object containing the authenticated user's information.
  ///
  /// Throws an exception if:
  /// - Authentication fails or is cancelled by the user
  /// - Platform is not iOS or macOS
  Future<User> call() {
    return repository.signInWithApple();
  }
}

