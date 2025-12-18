import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// 현재 사용자 정보 가져오기 유스케이스
class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<User?> call() {
    return repository.getCurrentUser();
  }
}

