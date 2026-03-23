import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_in_with_apple_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/delete_account_usecase.dart';
import '../../../../core/services/auth_service.dart';

// ============================================
// Authentication Providers
// ============================================

/// Provides the authentication repository instance.
///
/// This provider gives access to the [AuthRepository] implementation
/// from the auth service layer.
///
/// Example:
/// ```dart
/// final repository = ref.watch(authRepositoryProvider);
/// final user = await repository.getCurrentUser();
/// ```
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return ref.watch(authServiceProvider);
});

// ============================================
// Use Case Providers
// ============================================

/// Provides the Google Sign-In use case.
///
/// This provider creates a [SignInWithGoogleUseCase] instance with
/// the authentication repository.
///
/// Example:
/// ```dart
/// final useCase = ref.read(signInWithGoogleUseCaseProvider);
/// await useCase();
/// ```
final signInWithGoogleUseCaseProvider =
    Provider<SignInWithGoogleUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignInWithGoogleUseCase(repository);
});

/// Provides the Apple Sign-In use case.
///
/// This provider creates a [SignInWithAppleUseCase] instance with
/// the authentication repository.
///
/// Note: Only functional on iOS and macOS platforms.
///
/// Example:
/// ```dart
/// final useCase = ref.read(signInWithAppleUseCaseProvider);
/// await useCase();
/// ```
final signInWithAppleUseCaseProvider =
    Provider<SignInWithAppleUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignInWithAppleUseCase(repository);
});

/// Provides the get current user use case.
///
/// This provider creates a [GetCurrentUserUseCase] instance with
/// the authentication repository.
///
/// Example:
/// ```dart
/// final useCase = ref.read(getCurrentUserUseCaseProvider);
/// final user = await useCase();
/// ```
final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUseCase(repository);
});

/// Provides the sign-out use case.
///
/// This provider creates a [SignOutUseCase] instance with
/// the authentication repository.
///
/// Example:
/// ```dart
/// final useCase = ref.read(signOutUseCaseProvider);
/// await useCase();
/// ```
final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignOutUseCase(repository);
});

/// Provides the delete account use case.
///
/// This provider creates a [DeleteAccountUseCase] instance with
/// the authentication repository.
///
/// Example:
/// ```dart
/// final useCase = ref.read(deleteAccountUseCaseProvider);
/// await useCase();
/// ```
final deleteAccountUseCaseProvider = Provider<DeleteAccountUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return DeleteAccountUseCase(repository);
});

// ============================================
// State Providers
// ============================================

/// Provides a stream of the current user's authentication state.
///
/// This provider emits:
/// - A [User] object when a user is signed in
/// - null when no user is signed in
///
/// The stream automatically updates when authentication state changes.
///
/// Example:
/// ```dart
/// final userAsync = ref.watch(currentUserProvider);
/// userAsync.when(
///   data: (user) => user != null
///     ? Text('Welcome ${user.email}')
///     : Text('Please sign in'),
///   loading: () => CircularProgressIndicator(),
///   error: (e, _) => Text('Error: $e'),
/// );
/// ```
final currentUserProvider = StreamProvider<User?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges();
});

/// Provides whether Apple Sign-In is available on the current platform.
///
/// Returns true only on iOS and macOS platforms.
///
/// Example:
/// ```dart
/// final isAvailable = ref.watch(isAppleSignInAvailableProvider);
/// if (isAvailable) {
///   // Show Apple Sign-In button
/// }
/// ```
final isAppleSignInAvailableProvider = Provider<bool>((ref) {
  return Platform.isIOS || Platform.isMacOS;
});

