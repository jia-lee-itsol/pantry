import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/household.dart';
import '../../domain/entities/household_member.dart';
import 'household_member_model.dart';

class HouseholdModel extends Household {
  const HouseholdModel({
    required super.id,
    required super.name,
    required super.createdAt,
    required super.ownerId,
    required super.members,
  });

  factory HouseholdModel.fromEntity(Household household) {
    return HouseholdModel(
      id: household.id,
      name: household.name,
      createdAt: household.createdAt,
      ownerId: household.ownerId,
      members: household.members,
    );
  }

  factory HouseholdModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final membersData = data['members'] as Map<String, dynamic>? ?? {};

    final members = <String, HouseholdMember>{};
    membersData.forEach((userId, memberData) {
      members[userId] = HouseholdMemberModel.fromMap(
        userId,
        memberData as Map<String, dynamic>,
      );
    });

    return HouseholdModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ownerId: data['ownerId'] as String? ?? '',
      members: members,
    );
  }

  Map<String, dynamic> toMap() {
    final membersMap = <String, dynamic>{};
    members.forEach((userId, member) {
      membersMap[userId] = HouseholdMemberModel.fromEntity(member).toMap();
    });

    return {
      'name': name,
      'createdAt': Timestamp.fromDate(createdAt),
      'ownerId': ownerId,
      'members': membersMap,
    };
  }

  Household toEntity() {
    return Household(
      id: id,
      name: name,
      createdAt: createdAt,
      ownerId: ownerId,
      members: members,
    );
  }
}
