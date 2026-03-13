import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/domain/entities/user_profile.dart';
import '../../../auth/data/models/user_profile_model.dart';

/// Username 관련 Firestore 데이터소스
class UsernameFirestoreDataSource {
  final FirebaseFirestore _firestore;

  static const String _usersCollection = 'users';
  static const String _usernamesCollection = 'usernames';

  UsernameFirestoreDataSource({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _usersRef => _firestore.collection(_usersCollection);
  CollectionReference get _usernamesRef =>
      _firestore.collection(_usernamesCollection);

  /// 아이디 사용 가능 여부 확인
  Future<bool> isUsernameAvailable(String username) async {
    final doc = await _usernamesRef.doc(username.toLowerCase()).get();
    return !doc.exists;
  }

  /// 아이디 등록
  Future<void> registerUsername(String userId, String username) async {
    final lowerUsername = username.toLowerCase();
    final now = DateTime.now();

    // Use batch write for atomicity
    final batch = _firestore.batch();

    // Create username document
    batch.set(_usernamesRef.doc(lowerUsername), {
      'userId': userId,
      'createdAt': Timestamp.fromDate(now),
    });

    // Update user document
    batch.set(
      _usersRef.doc(userId),
      {
        'username': lowerUsername,
        'usernameSetAt': Timestamp.fromDate(now),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  /// 사용자 ID로 아이디 조회
  Future<String?> getUsernameByUserId(String userId) async {
    final doc = await _usersRef.doc(userId).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>?;
    return data?['username'] as String?;
  }

  /// 아이디로 사용자 ID 조회
  Future<String?> getUserIdByUsername(String username) async {
    final doc = await _usernamesRef.doc(username.toLowerCase()).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>?;
    return data?['userId'] as String?;
  }

  /// 사용자가 이미 아이디를 가지고 있는지 확인
  Future<bool> hasUsername(String userId) async {
    final username = await getUsernameByUserId(userId);
    return username != null;
  }

  /// 아이디로 유저 프로필 검색
  Future<UserProfile?> findUserByUsername(String username) async {
    final userId = await getUserIdByUsername(username);
    if (userId == null) return null;

    final userDoc = await _usersRef.doc(userId).get();
    if (!userDoc.exists) return null;

    final userData = userDoc.data() as Map<String, dynamic>?;
    if (userData == null) return null;

    return UserProfileModel(
      id: userId,
      username: userData['username'] as String? ?? username.toLowerCase(),
      displayName: userData['displayName'] as String?,
      photoUrl: userData['photoUrl'] as String?,
    );
  }
}
