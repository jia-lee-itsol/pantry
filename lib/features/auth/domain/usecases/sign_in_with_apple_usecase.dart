import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// 애플 로그인 유스케이스
class SignInWithAppleUseCase {
  final AuthRepository repository;

  SignInWithAppleUseCase(this.repository);

  Future<User> call() {
    return repository.signInWithApple();
  }
}

