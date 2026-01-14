import '../entities/user.dart';

/// 인증 리포지토리 인터페이스
abstract class AuthRepository {
  /// 현재 로그인한 사용자 정보를 가져옵니다.
  Future<User?> getCurrentUser();

  /// 구글 로그인을 수행합니다.
  Future<User> signInWithGoogle();

  /// 애플 로그인을 수행합니다.
  Future<User> signInWithApple();

  /// 로그아웃을 수행합니다.
  Future<void> signOut();

  /// 계정을 삭제합니다.
  Future<void> deleteAccount();

  /// 인증 상태 변화를 스트림으로 반환합니다.
  Stream<User?> authStateChanges();
}

