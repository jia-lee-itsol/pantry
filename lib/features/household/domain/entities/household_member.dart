import 'household_role.dart';

/// Represents a member of a household.
///
/// Each member has a role that determines their permissions within
/// the household. Members are stored in the household document
/// as a map keyed by their user ID.
///
/// ## Fields
/// - [id]: The user's Firebase Auth UID
/// - [role]: Permission level (owner, editor, viewer)
/// - [joinedAt]: When the user joined the household
/// - [displayName]: Optional display name from user profile
/// - [photoUrl]: Optional profile photo URL
/// - [email]: Optional email address
class HouseholdMember {
  /// Firebase Auth user ID
  final String id;

  /// Member's permission level within the household
  final HouseholdRole role;

  /// Timestamp when the member joined the household
  final DateTime joinedAt;

  /// Display name (from Firebase Auth or custom)
  final String? displayName;

  /// URL to the member's profile photo
  final String? photoUrl;

  /// Member's email address
  final String? email;

  const HouseholdMember({
    required this.id,
    required this.role,
    required this.joinedAt,
    this.displayName,
    this.photoUrl,
    this.email,
  });

  HouseholdMember copyWith({
    String? id,
    HouseholdRole? role,
    DateTime? joinedAt,
    String? displayName,
    String? photoUrl,
    String? email,
  }) {
    return HouseholdMember(
      id: id ?? this.id,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      email: email ?? this.email,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HouseholdMember && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
