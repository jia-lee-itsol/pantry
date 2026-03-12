/// 유저 프로필 엔티티 (검색 결과용)
class UserProfile {
  final String id;
  final String username;
  final String? displayName;
  final String? photoUrl;

  const UserProfile({
    required this.id,
    required this.username,
    this.displayName,
    this.photoUrl,
  });

  /// 표시할 이름 (displayName이 없으면 username 반환)
  String get name => displayName ?? username;

  UserProfile copyWith({
    String? id,
    String? username,
    String? displayName,
    String? photoUrl,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
