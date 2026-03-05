import 'household_member.dart';
import 'household_role.dart';

class Household {
  final String id;
  final String name;
  final DateTime createdAt;
  final String ownerId;
  final Map<String, HouseholdMember> members;

  const Household({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.ownerId,
    required this.members,
  });

  List<HouseholdMember> get membersList => members.values.toList();

  HouseholdMember? getMember(String userId) => members[userId];

  HouseholdRole? getMemberRole(String userId) => members[userId]?.role;

  bool isMember(String userId) => members.containsKey(userId);

  bool isOwner(String userId) => getMemberRole(userId) == HouseholdRole.owner;

  bool canEdit(String userId) => getMemberRole(userId)?.canEdit ?? false;

  int get memberCount => members.length;

  Household copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    String? ownerId,
    Map<String, HouseholdMember>? members,
  }) {
    return Household(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      ownerId: ownerId ?? this.ownerId,
      members: members ?? this.members,
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
