import 'household_role.dart';

class HouseholdMember {
  final String id;
  final HouseholdRole role;
  final DateTime joinedAt;
  final String? displayName;
  final String? photoUrl;
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
