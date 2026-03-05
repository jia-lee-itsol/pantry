enum AlertType {
  expiry,
  stock,
  member, // 멤버 가입/탈퇴 알림
}

class Alert {
  final String id;
  final AlertType type;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  const Alert({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });
}

