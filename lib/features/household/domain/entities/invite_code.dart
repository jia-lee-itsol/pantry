class InviteCode {
  final String id;
  final String code;
  final String householdId;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String createdBy;
  final bool used;

  const InviteCode({
    required this.id,
    required this.code,
    required this.householdId,
    required this.createdAt,
    required this.expiresAt,
    required this.createdBy,
    this.used = false,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  bool get isValid => !used && !isExpired;

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
  }) {
    return InviteCode(
      id: id ?? this.id,
      code: code ?? this.code,
      householdId: householdId ?? this.householdId,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      createdBy: createdBy ?? this.createdBy,
      used: used ?? this.used,
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
