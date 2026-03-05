enum HouseholdRole {
  owner,
  editor,
  viewer;

  bool get canEdit => this == HouseholdRole.owner || this == HouseholdRole.editor;
  bool get canManageMembers => this == HouseholdRole.owner;
  bool get canDeleteHousehold => this == HouseholdRole.owner;
  bool get canInvite => this == HouseholdRole.owner;

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
