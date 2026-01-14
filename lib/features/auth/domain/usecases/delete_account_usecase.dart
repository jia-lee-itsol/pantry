import '../repositories/auth_repository.dart';

/// 계정 삭제 유스케이스
class DeleteAccountUseCase {
  final AuthRepository repository;

  DeleteAccountUseCase(this.repository);

  Future<void> call() {
    return repository.deleteAccount();
  }
}
