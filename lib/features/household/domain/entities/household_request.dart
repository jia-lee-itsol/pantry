/// 공동관리 요청 상태
enum HouseholdRequestStatus {
  pending,
  accepted,
  rejected;

  String get displayName {
    switch (this) {
      case HouseholdRequestStatus.pending:
        return '대기중';
      case HouseholdRequestStatus.accepted:
        return '수락됨';
      case HouseholdRequestStatus.rejected:
        return '거절됨';
    }
  }
}

/// 공동관리 요청 엔티티
class HouseholdRequest {
  final String id;
  final String senderId;
  final String senderUsername;
  final String? senderDisplayName;
  final String? senderPhotoUrl;
  final String receiverId;
  final String receiverUsername;
  final String householdId;
  final String householdName;
  final HouseholdRequestStatus status;
  final DateTime createdAt;
  final DateTime? respondedAt;

  const HouseholdRequest({
    required this.id,
    required this.senderId,
    required this.senderUsername,
    this.senderDisplayName,
    this.senderPhotoUrl,
    required this.receiverId,
    required this.receiverUsername,
    required this.householdId,
    required this.householdName,
    required this.status,
    required this.createdAt,
    this.respondedAt,
  });

  bool get isPending => status == HouseholdRequestStatus.pending;
  bool get isAccepted => status == HouseholdRequestStatus.accepted;
  bool get isRejected => status == HouseholdRequestStatus.rejected;

  HouseholdRequest copyWith({
    String? id,
    String? senderId,
    String? senderUsername,
    String? senderDisplayName,
    String? senderPhotoUrl,
    String? receiverId,
    String? receiverUsername,
    String? householdId,
    String? householdName,
    HouseholdRequestStatus? status,
    DateTime? createdAt,
    DateTime? respondedAt,
  }) {
    return HouseholdRequest(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderUsername: senderUsername ?? this.senderUsername,
      senderDisplayName: senderDisplayName ?? this.senderDisplayName,
      senderPhotoUrl: senderPhotoUrl ?? this.senderPhotoUrl,
      receiverId: receiverId ?? this.receiverId,
      receiverUsername: receiverUsername ?? this.receiverUsername,
      householdId: householdId ?? this.householdId,
      householdName: householdName ?? this.householdName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HouseholdRequest && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
