import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/invite_code.dart';

class InviteCodeModel extends InviteCode {
  const InviteCodeModel({
    required super.id,
    required super.code,
    required super.householdId,
    required super.createdAt,
    required super.expiresAt,
    required super.createdBy,
    super.used,
  });

  factory InviteCodeModel.fromEntity(InviteCode inviteCode) {
    return InviteCodeModel(
      id: inviteCode.id,
      code: inviteCode.code,
      householdId: inviteCode.householdId,
      createdAt: inviteCode.createdAt,
      expiresAt: inviteCode.expiresAt,
      createdBy: inviteCode.createdBy,
      used: inviteCode.used,
    );
  }

  factory InviteCodeModel.fromFirestore(DocumentSnapshot doc, String householdId) {
    final data = doc.data() as Map<String, dynamic>;
    return InviteCodeModel(
      id: doc.id,
      code: data['code'] as String? ?? '',
      householdId: householdId,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] as String? ?? '',
      used: data['used'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'createdBy': createdBy,
      'used': used,
    };
  }

  InviteCode toEntity() {
    return InviteCode(
      id: id,
      code: code,
      householdId: householdId,
      createdAt: createdAt,
      expiresAt: expiresAt,
      createdBy: createdBy,
      used: used,
    );
  }
}
