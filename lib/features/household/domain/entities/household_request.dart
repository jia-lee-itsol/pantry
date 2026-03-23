/// Status of a household join request.
///
/// Represents the lifecycle state of a request from creation to resolution.
enum HouseholdRequestStatus {
  /// Request is waiting for the receiver to respond
  pending,

  /// Request was accepted, user has joined the household
  accepted,

  /// Request was rejected by the receiver
  rejected;

  /// Localized display name for UI
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

/// Represents a request to invite a user to join a household.
///
/// This is an alternative to invite codes - instead of sharing a code,
/// the household owner can search for a user by username and send them
/// a direct invitation.
///
/// ## Flow
/// 1. Sender searches for user by username
/// 2. Sender creates a request targeting the found user
/// 3. Receiver sees the request in their notifications
/// 4. Receiver accepts or rejects the request
/// 5. If accepted, receiver is added to the household
///
/// ## State Transitions
/// ```
/// pending -> accepted (receiver joins household)
/// pending -> rejected (no action taken)
/// pending -> deleted  (sender cancels)
/// ```
class HouseholdRequest {
  /// Unique Firestore document ID
  final String id;

  /// User ID of the person sending the invitation
  final String senderId;

  /// Username of the sender (for display purposes)
  final String senderUsername;

  /// Display name of the sender (optional)
  final String? senderDisplayName;

  /// Profile photo URL of the sender (optional)
  final String? senderPhotoUrl;

  /// User ID of the person being invited
  final String receiverId;

  /// Username of the receiver (for display purposes)
  final String receiverUsername;

  /// ID of the household the receiver is being invited to
  final String householdId;

  /// Name of the household (for display purposes)
  final String householdName;

  /// Current status of the request
  final HouseholdRequestStatus status;

  /// When the request was created
  final DateTime createdAt;

  /// When the receiver responded (null if still pending)
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

  /// Whether the request is still waiting for a response
  bool get isPending => status == HouseholdRequestStatus.pending;

  /// Whether the request was accepted
  bool get isAccepted => status == HouseholdRequestStatus.accepted;

  /// Whether the request was rejected
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
