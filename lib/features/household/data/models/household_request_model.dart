import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/household_request.dart';

class HouseholdRequestModel extends HouseholdRequest {
  const HouseholdRequestModel({
    required super.id,
    required super.senderId,
    required super.senderUsername,
    super.senderDisplayName,
    super.senderPhotoUrl,
    required super.receiverId,
    required super.receiverUsername,
    required super.householdId,
    required super.householdName,
    required super.status,
    required super.createdAt,
    super.respondedAt,
  });

  factory HouseholdRequestModel.fromEntity(HouseholdRequest request) {
    return HouseholdRequestModel(
      id: request.id,
      senderId: request.senderId,
      senderUsername: request.senderUsername,
      senderDisplayName: request.senderDisplayName,
      senderPhotoUrl: request.senderPhotoUrl,
      receiverId: request.receiverId,
      receiverUsername: request.receiverUsername,
      householdId: request.householdId,
      householdName: request.householdName,
      status: request.status,
      createdAt: request.createdAt,
      respondedAt: request.respondedAt,
    );
  }

  factory HouseholdRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return HouseholdRequestModel(
      id: doc.id,
      senderId: data['senderId'] as String? ?? '',
      senderUsername: data['senderUsername'] as String? ?? '',
      senderDisplayName: data['senderDisplayName'] as String?,
      senderPhotoUrl: data['senderPhotoUrl'] as String?,
      receiverId: data['receiverId'] as String? ?? '',
      receiverUsername: data['receiverUsername'] as String? ?? '',
      householdId: data['householdId'] as String? ?? '',
      householdName: data['householdName'] as String? ?? '',
      status: _parseStatus(data['status'] as String?),
      createdAt: _parseDateTime(data['createdAt']),
      respondedAt: data['respondedAt'] != null
          ? _parseDateTime(data['respondedAt'])
          : null,
    );
  }

  static HouseholdRequestStatus _parseStatus(String? status) {
    switch (status) {
      case 'accepted':
        return HouseholdRequestStatus.accepted;
      case 'rejected':
        return HouseholdRequestStatus.rejected;
      case 'pending':
      default:
        return HouseholdRequestStatus.pending;
    }
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.parse(value);
    }
    return DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderUsername': senderUsername,
      'senderDisplayName': senderDisplayName,
      'senderPhotoUrl': senderPhotoUrl,
      'receiverId': receiverId,
      'receiverUsername': receiverUsername,
      'householdId': householdId,
      'householdName': householdName,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'respondedAt':
          respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
    };
  }

  HouseholdRequest toEntity() {
    return HouseholdRequest(
      id: id,
      senderId: senderId,
      senderUsername: senderUsername,
      senderDisplayName: senderDisplayName,
      senderPhotoUrl: senderPhotoUrl,
      receiverId: receiverId,
      receiverUsername: receiverUsername,
      householdId: householdId,
      householdName: householdName,
      status: status,
      createdAt: createdAt,
      respondedAt: respondedAt,
    );
  }
}
