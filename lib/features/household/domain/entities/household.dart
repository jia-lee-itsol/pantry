import 'household_member.dart';
import 'household_role.dart';

/// Represents a household (family/group) that shares a fridge and pantry.
///
/// A household is a group of users who share access to fridge items,
/// stock items, and other shared resources. Each household has:
/// - One owner with full administrative privileges
/// - Multiple members with varying permission levels
///
/// ## Permission Model
/// Members can have different roles (see [HouseholdRole]):
/// - `owner`: Full control including member management
/// - `editor`: Can add, edit, and delete items
/// - `viewer`: Read-only access
///
/// ## Example
/// ```dart
/// final household = Household(
///   id: 'abc123',
///   name: 'My Family',
///   createdAt: DateTime.now(),
///   ownerId: 'user123',
///   members: {
///     'user123': HouseholdMember(id: 'user123', role: HouseholdRole.owner, ...),
///   },
/// );
/// ```
class Household {
  /// Unique Firestore document ID
  final String id;

  /// Display name of the household (e.g., "Smith Family")
  final String name;

  /// Timestamp when the household was created
  final DateTime createdAt;

  /// User ID of the household owner
  final String ownerId;

  /// Map of member ID to [HouseholdMember] objects
  final Map<String, HouseholdMember> members;

  /// Permanent invite code for this household (never expires)
  final String inviteCode;

  const Household({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.ownerId,
    required this.members,
    required this.inviteCode,
  });

  /// Returns all members as a list
  List<HouseholdMember> get membersList => members.values.toList();

  /// Gets a specific member by user ID, or null if not found
  HouseholdMember? getMember(String userId) => members[userId];

  /// Gets the role of a specific member, or null if not a member
  HouseholdRole? getMemberRole(String userId) => members[userId]?.role;

  /// Checks if a user is a member of this household
  bool isMember(String userId) => members.containsKey(userId);

  /// Checks if a user is the owner of this household
  bool isOwner(String userId) => getMemberRole(userId) == HouseholdRole.owner;

  /// Checks if a user has edit permissions (owner or editor)
  bool canEdit(String userId) => getMemberRole(userId)?.canEdit ?? false;

  /// Total number of members in the household
  int get memberCount => members.length;

  Household copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    String? ownerId,
    Map<String, HouseholdMember>? members,
    String? inviteCode,
  }) {
    return Household(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      ownerId: ownerId ?? this.ownerId,
      members: members ?? this.members,
      inviteCode: inviteCode ?? this.inviteCode,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Household && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
