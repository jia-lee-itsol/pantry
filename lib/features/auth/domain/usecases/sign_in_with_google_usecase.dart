import 'package:flutter/foundation.dart';

import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// 구글 로그인 유스케이스
class SignInWithGoogleUseCase {
  final AuthRepository repository;

  SignInWithGoogleUseCase(this.repository);

  Future<User> call() {
    debugPrint('[SignInWithGoogleUseCase] call() 호출됨');
    debugPrint('[SignInWithGoogleUseCase] repository.signInWithGoogle() 호출');
    final result = repository.signInWithGoogle();
    debugPrint('[SignInWithGoogleUseCase] repository.signInWithGoogle() 완료');
    return result;
  }
}

