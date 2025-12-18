import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/data/datasources/auth_firebase_datasource.dart';
import '../../features/auth/data/repositories_impl/auth_repository_impl.dart';

/// 인증 서비스 프로바이더
final authServiceProvider = Provider<AuthRepository>((ref) {
  final dataSource = AuthFirebaseDataSource();
  return AuthRepositoryImpl(dataSource);
});

