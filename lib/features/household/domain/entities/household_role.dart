/// Defines the permission levels for household members.
///
/// Each role has different capabilities within a household:
///
/// | Role    | Edit Items | Manage Members | Delete Household | Invite |
/// |---------|------------|----------------|------------------|--------|
/// | owner   | ✓          | ✓              | ✓                | ✓      |
/// | editor  | ✓          | ✗              | ✗                | ✗      |
/// | viewer  | ✗          | ✗              | ✗                | ✗      |
///
/// ## Usage
/// ```dart
/// if (member.role.canEdit) {
///   // Allow editing
/// }
/// ```
enum HouseholdRole {
  /// Full administrative access including member management
  owner,

  /// Can add, edit, and delete items but cannot manage members
  editor,

  /// Read-only access to household data
  viewer;

  /// Whether this role can add, edit, or delete items
  bool get canEdit => this == HouseholdRole.owner || this == HouseholdRole.editor;

  /// Whether this role can add/remove members or change roles
  bool get canManageMembers => this == HouseholdRole.owner;

  /// Whether this role can delete the entire household
  bool get canDeleteHousehold => this == HouseholdRole.owner;

  /// Whether this role can generate invite codes
  bool get canInvite => this == HouseholdRole.owner;

  /// Localized display name for UI
  String get displayName {
    switch (this) {
      case HouseholdRole.owner:
        return '소유자';
      case HouseholdRole.editor:
        return '편집자';
      case HouseholdRole.viewer:
        return '조회자';
    }
  }

  /// Localized description of role capabilities for UI
  String get description {
    switch (this) {
      case HouseholdRole.owner:
        return '모든 권한 (멤버 관리 포함)';
      case HouseholdRole.editor:
        return '상품 추가/수정/삭제 가능';
      case HouseholdRole.viewer:
        return '조회만 가능';
    }
  }

  /// Parses a role from its string representation.
  ///
  /// Defaults to [viewer] if the value is not recognized.
  static HouseholdRole fromString(String value) {
    switch (value) {
      case 'owner':
        return HouseholdRole.owner;
      case 'editor':
        return HouseholdRole.editor;
      case 'viewer':
        return HouseholdRole.viewer;
      default:
        return HouseholdRole.viewer;
    }
  }
}
