import '../repositories/auth_repository.dart';

/// 로그아웃 유스케이스
class SignOutUseCase {
  final AuthRepository repository;

  SignOutUseCase(this.repository);

  Future<void> call() {
    return repository.signOut();
  }
}

