/// 사용자 엔티티
class User {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? providerId; // 'google.com' or 'apple.com'
  final String? username; // 고유 아이디 (한 번만 설정 가능)

  const User({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    this.providerId,
    this.username,
  });

  /// username이 설정되어 있는지 확인
  bool get hasUsername => username != null && username!.isNotEmpty;

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? providerId,
    String? username,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      providerId: providerId ?? this.providerId,
      username: username ?? this.username,
    );
  }
}

