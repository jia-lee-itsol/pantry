import '../../../auth/domain/entities/user_profile.dart';

/// Username 관리를 위한 Repository 인터페이스
abstract class UsernameRepository {
  /// 아이디 사용 가능 여부 확인
  Future<bool> isUsernameAvailable(String username);

  /// 아이디 등록
  Future<void> registerUsername(String userId, String username);

  /// 사용자 ID로 아이디 조회
  Future<String?> getUsernameByUserId(String userId);

  /// 아이디로 사용자 ID 조회
  Future<String?> getUserIdByUsername(String username);

  /// 아이디로 유저 프로필 검색
  Future<UserProfile?> findUserByUsername(String username);
}
