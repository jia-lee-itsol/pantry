import '../../../auth/domain/entities/user_profile.dart';
import '../repositories/username_repository.dart';

class SearchUserUseCase {
  final UsernameRepository repository;

  SearchUserUseCase(this.repository);

  Future<UserProfile?> call(String username) {
    return repository.findUserByUsername(username);
  }
}
