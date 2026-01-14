import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_in_with_apple_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/delete_account_usecase.dart';
import '../../../../core/services/auth_service.dart';

/// 인증 리포지토리 프로바이더
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return ref.watch(authServiceProvider);
});

/// 구글 로그인 유스케이스 프로바이더
final signInWithGoogleUseCaseProvider =
    Provider<SignInWithGoogleUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignInWithGoogleUseCase(repository);
});

/// 애플 로그인 유스케이스 프로바이더
final signInWithAppleUseCaseProvider =
    Provider<SignInWithAppleUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignInWithAppleUseCase(repository);
});

/// 현재 사용자 정보 가져오기 유스케이스 프로바이더
final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUseCase(repository);
});

/// 로그아웃 유스케이스 프로바이더
final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignOutUseCase(repository);
});

/// 계정 삭제 유스케이스 프로바이더
final deleteAccountUseCaseProvider = Provider<DeleteAccountUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return DeleteAccountUseCase(repository);
});

/// 현재 로그인한 사용자 프로바이더
final currentUserProvider = StreamProvider<User?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges();
});

/// 애플 로그인 사용 가능 여부 (iOS/macOS만)
final isAppleSignInAvailableProvider = Provider<bool>((ref) {
  return Platform.isIOS || Platform.isMacOS;
});

