/// 사용자 엔티티
class User {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? providerId; // 'google.com' or 'apple.com'

  const User({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    this.providerId,
  });

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? providerId,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      providerId: providerId ?? this.providerId,
    );
  }
}

