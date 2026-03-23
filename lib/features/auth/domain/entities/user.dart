// ============================================
// User Entity
// ============================================

/// Represents a user in the authentication domain.
///
/// This entity contains core user information obtained from authentication
/// providers (Google, Apple) and stored in Firebase.
///
/// Properties:
/// - [id]: Unique user identifier (Firebase UID)
/// - [email]: User's email address (optional)
/// - [displayName]: User's display name from auth provider (optional)
/// - [photoUrl]: URL to user's profile photo (optional)
/// - [providerId]: OAuth provider identifier (e.g., 'google.com', 'apple.com')
/// - [username]: User's unique username for the app (optional, set once)
///
/// Example:
/// ```dart
/// final user = User(
///   id: 'abc123',
///   email: 'user@example.com',
///   displayName: 'John Doe',
///   providerId: 'google.com',
/// );
/// print('Has username: ${user.hasUsername}');
/// ```
class User {
  /// Unique user identifier (Firebase UID)
  final String id;

  /// User's email address
  final String? email;

  /// User's display name from authentication provider
  final String? displayName;

  /// URL to user's profile photo
  final String? photoUrl;

  /// OAuth provider identifier (e.g., 'google.com', 'apple.com')
  final String? providerId;

  /// User's unique username for the app (can only be set once)
  final String? username;

  /// Creates a new User instance.
  ///
  /// Parameters:
  /// - [id]: Required unique user identifier
  /// - [email]: Optional email address
  /// - [displayName]: Optional display name
  /// - [photoUrl]: Optional profile photo URL
  /// - [providerId]: Optional OAuth provider identifier
  /// - [username]: Optional unique username
  const User({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    this.providerId,
    this.username,
  });

  /// Checks if the user has set a username.
  ///
  /// Returns true if username is not null and not empty.
  bool get hasUsername => username != null && username!.isNotEmpty;

  /// Creates a copy of this User with the given fields replaced.
  ///
  /// Parameters: All parameters are optional. If not provided, the
  /// existing value is used.
  ///
  /// Returns a new [User] instance with updated values.
  ///
  /// Example:
  /// ```dart
  /// final updatedUser = user.copyWith(
  ///   displayName: 'New Name',
  ///   username: 'newusername',
  /// );
  /// ```
  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? providerId,
    String? username,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      providerId: providerId ?? this.providerId,
      username: username ?? this.username,
    );
  }
}

