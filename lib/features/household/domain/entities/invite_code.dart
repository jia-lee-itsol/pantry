/// Represents an invite code used to join a household.
///
/// Invite codes are time-limited (24 hours by default) and can only be used once.
/// They allow new members to join a household without needing direct approval
/// from the owner.
///
/// ## Lifecycle
/// 1. Owner generates code via [HouseholdRepository.generateInviteCode]
/// 2. Code is shared with invitee (QR code, text, etc.)
/// 3. Invitee enters code to join the household
/// 4. Code is marked as used and cannot be reused
///
/// ## Validation
/// Use [isValid] to check if a code can still be used:
/// - Not expired ([isExpired])
/// - Not already used ([used])
class InviteCode {
  /// Unique Firestore document ID
  final String id;

  /// 6-character alphanumeric code (e.g., "ABC123")
  final String code;

  /// ID of the household this code grants access to
  final String householdId;

  /// When the code was generated
  final DateTime createdAt;

  /// When the code expires (typically 24 hours after creation)
  /// For permanent codes, this is set to a far future date
  final DateTime expiresAt;

  /// User ID of the member who generated this code
  final String createdBy;

  /// Whether the code has been used to join the household
  final bool used;

  /// Whether this is a permanent invite code (never expires, can be reused)
  final bool isPermanent;

  const InviteCode({
    required this.id,
    required this.code,
    required this.householdId,
    required this.createdAt,
    required this.expiresAt,
    required this.createdBy,
    this.used = false,
    this.isPermanent = false,
  });

  /// Whether the code has passed its expiration time
  /// Permanent codes never expire
  bool get isExpired => !isPermanent && DateTime.now().isAfter(expiresAt);

  /// Whether the code can still be used
  /// Permanent codes are always valid, temporary codes must not be used or expired
  bool get isValid => isPermanent || (!used && !isExpired);

  /// Time remaining before the code expires
  ///
  /// Returns [Duration.zero] if already expired.
  Duration get remainingTime {
    final now = DateTime.now();
    if (now.isAfter(expiresAt)) return Duration.zero;
    return expiresAt.difference(now);
  }

  InviteCode copyWith({
    String? id,
    String? code,
    String? householdId,
    DateTime? createdAt,
    DateTime? expiresAt,
    String? createdBy,
    bool? used,
    bool? isPermanent,
  }) {
    return InviteCode(
      id: id ?? this.id,
      code: code ?? this.code,
      householdId: householdId ?? this.householdId,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      createdBy: createdBy ?? this.createdBy,
      used: used ?? this.used,
      isPermanent: isPermanent ?? this.isPermanent,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InviteCode && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
