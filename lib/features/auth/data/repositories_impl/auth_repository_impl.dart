import 'package:flutter/foundation.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_firebase_datasource.dart';

/// 인증 리포지토리 구현
class AuthRepositoryImpl implements AuthRepository {
  final AuthFirebaseDataSource dataSource;

  AuthRepositoryImpl(this.dataSource);

  @override
  Future<User?> getCurrentUser() async {
    return dataSource.getCurrentUser();
  }

  @override
  Future<User> signInWithGoogle() async {
    debugPrint('[AuthRepositoryImpl] signInWithGoogle() 호출됨');
    debugPrint('[AuthRepositoryImpl] dataSource.signInWithGoogle() 호출');
    final result = await dataSource.signInWithGoogle();
    debugPrint('[AuthRepositoryImpl] dataSource.signInWithGoogle() 완료');
    return result;
  }

  @override
  Future<User> signInWithApple() async {
    return await dataSource.signInWithApple();
  }

  @override
  Future<void> signOut() async {
    await dataSource.signOut();
  }

  @override
  Stream<User?> authStateChanges() {
    return dataSource.authStateChanges();
  }
}

