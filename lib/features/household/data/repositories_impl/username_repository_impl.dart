import '../../../auth/domain/entities/user_profile.dart';
import '../../domain/repositories/username_repository.dart';
import '../datasources/username_firestore_datasource.dart';

class UsernameRepositoryImpl implements UsernameRepository {
  final UsernameFirestoreDataSource _dataSource;

  UsernameRepositoryImpl(this._dataSource);

  @override
  Future<bool> isUsernameAvailable(String username) {
    return _dataSource.isUsernameAvailable(username);
  }

  @override
  Future<void> registerUsername(String userId, String username) {
    return _dataSource.registerUsername(userId, username);
  }

  @override
  Future<String?> getUsernameByUserId(String userId) {
    return _dataSource.getUsernameByUserId(userId);
  }

  @override
  Future<String?> getUserIdByUsername(String username) {
    return _dataSource.getUserIdByUsername(username);
  }

  @override
  Future<UserProfile?> findUserByUsername(String username) {
    return _dataSource.findUserByUsername(username);
  }
}
