// ============================================
// User Profile Entity
// ============================================

/// Represents a user profile used for search results and user discovery.
///
/// This is a lightweight entity containing minimal user information
/// needed for displaying users in search results or user lists.
///
/// Properties:
/// - [id]: Unique user identifier
/// - [username]: User's unique username
/// - [displayName]: User's display name (optional)
/// - [photoUrl]: URL to user's profile photo (optional)
///
/// Example:
/// ```dart
/// final profile = UserProfile(
///   id: 'abc123',
///   username: 'johndoe',
///   displayName: 'John Doe',
///   photoUrl: 'https://example.com/photo.jpg',
/// );
/// print('Display name: ${profile.name}');
/// ```
class UserProfile {
  /// Unique user identifier
  final String id;

  /// User's unique username
  final String username;

  /// User's display name
  final String? displayName;

  /// URL to user's profile photo
  final String? photoUrl;

  /// Creates a new UserProfile instance.
  ///
  /// Parameters:
  /// - [id]: Required unique user identifier
  /// - [username]: Required unique username
  /// - [displayName]: Optional display name
  /// - [photoUrl]: Optional profile photo URL
  const UserProfile({
    required this.id,
    required this.username,
    this.displayName,
    this.photoUrl,
  });

  /// Gets the display name to show in the UI.
  ///
  /// Returns [displayName] if available, otherwise returns [username].
  String get name => displayName ?? username;

  /// Creates a copy of this UserProfile with the given fields replaced.
  ///
  /// Parameters: All parameters are optional. If not provided, the
  /// existing value is used.
  ///
  /// Returns a new [UserProfile] instance with updated values.
  ///
  /// Example:
  /// ```dart
  /// final updatedProfile = profile.copyWith(
  ///   displayName: 'New Display Name',
  /// );
  /// ```
  UserProfile copyWith({
    String? id,
    String? username,
    String? displayName,
    String? photoUrl,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  /// Checks equality based on user ID.
  ///
  /// Two UserProfile instances are equal if they have the same [id].
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.id == id;
  }

  /// Returns hash code based on user ID.
  @override
  int get hashCode => id.hashCode;
}
