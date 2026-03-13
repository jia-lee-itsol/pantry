import '../repositories/username_repository.dart';

/// 아이디 등록 UseCase
class RegisterUsernameUseCase {
  final UsernameRepository _usernameRepository;

  RegisterUsernameUseCase(this._usernameRepository);

  /// 아이디 등록
  ///
  /// [userId]: 사용자 Firebase UID
  /// [username]: 등록할 아이디 (영문+숫자, 3-20자)
  ///
  /// Throws:
  /// - [UsernameAlreadyRegisteredException]: 이미 아이디가 등록된 경우
  /// - [UsernameNotAvailableException]: 아이디가 이미 사용 중인 경우
  /// - [InvalidUsernameException]: 아이디 형식이 잘못된 경우
  Future<void> call({
    required String userId,
    required String username,
  }) async {
    // 1. 아이디 형식 검증
    final usernameRegex = RegExp(r'^[a-zA-Z0-9]{3,20}$');
    if (!usernameRegex.hasMatch(username)) {
      throw InvalidUsernameException('아이디는 영문과 숫자만 사용하여 3-20자로 입력해주세요');
    }

    // 2. 이미 아이디가 있는지 확인
    final existingUsername = await _usernameRepository.getUsernameByUserId(userId);
    if (existingUsername != null) {
      throw UsernameAlreadyRegisteredException('이미 아이디가 등록되어 있습니다');
    }

    // 3. 아이디 사용 가능 여부 확인
    final isAvailable = await _usernameRepository.isUsernameAvailable(username);
    if (!isAvailable) {
      throw UsernameNotAvailableException('이미 사용 중인 아이디입니다');
    }

    // 4. 아이디 등록
    await _usernameRepository.registerUsername(userId, username);
  }
}

class InvalidUsernameException implements Exception {
  final String message;
  InvalidUsernameException(this.message);
  @override
  String toString() => message;
}

class UsernameAlreadyRegisteredException implements Exception {
  final String message;
  UsernameAlreadyRegisteredException(this.message);
  @override
  String toString() => message;
}

class UsernameNotAvailableException implements Exception {
  final String message;
  UsernameNotAvailableException(this.message);
  @override
  String toString() => message;
}
