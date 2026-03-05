import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/household_member.dart';
import '../../domain/entities/household_role.dart';

class HouseholdMemberModel extends HouseholdMember {
  const HouseholdMemberModel({
    required super.id,
    required super.role,
    required super.joinedAt,
    super.displayName,
    super.photoUrl,
    super.email,
  });

  factory HouseholdMemberModel.fromEntity(HouseholdMember member) {
    return HouseholdMemberModel(
      id: member.id,
      role: member.role,
      joinedAt: member.joinedAt,
      displayName: member.displayName,
      photoUrl: member.photoUrl,
      email: member.email,
    );
  }

  factory HouseholdMemberModel.fromMap(String id, Map<String, dynamic> map) {
    return HouseholdMemberModel(
      id: id,
      role: HouseholdRole.fromString(map['role'] as String? ?? 'viewer'),
      joinedAt: (map['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      displayName: map['displayName'] as String?,
      photoUrl: map['photoUrl'] as String?,
      email: map['email'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'role': role.name,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'displayName': displayName,
      'photoUrl': photoUrl,
      'email': email,
    };
  }

  HouseholdMember toEntity() {
    return HouseholdMember(
      id: id,
      role: role,
      joinedAt: joinedAt,
      displayName: displayName,
      photoUrl: photoUrl,
      email: email,
    );
  }
}
