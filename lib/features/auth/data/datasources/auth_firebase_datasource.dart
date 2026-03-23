import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/user.dart';

// ============================================
// Firebase Authentication Data Source
// ============================================

/// Firebase Authentication data source for handling user authentication operations.
///
/// This class provides authentication functionality using Firebase Auth,
/// including Google Sign-In and Apple Sign-In integrations.
///
/// Responsibilities:
/// - Managing Firebase Authentication instance
/// - Handling Google OAuth flow
/// - Handling Apple OAuth flow
/// - Converting Firebase User to domain User entity
/// - Managing authentication state changes
///
/// Example:
/// ```dart
/// final dataSource = AuthFirebaseDataSource();
/// final user = await dataSource.signInWithGoogle();
/// print('Logged in as: ${user.email}');
/// ```
class AuthFirebaseDataSource {
  // ============================================
  // Private Fields
  // ============================================

  /// Firebase Authentication instance
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  /// Google Sign-In instance with iOS client ID from GoogleService-Info.plist
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '630905075034-fretpu1g28q0tpgq2ekakdtkt5q2fil1.apps.googleusercontent.com',
  );

  // ============================================
  // Public Methods
  // ============================================

  /// Gets the currently logged-in user information.
  ///
  /// Returns the current [User] if authenticated, null otherwise.
  ///
  /// Example:
  /// ```dart
  /// final user = dataSource.getCurrentUser();
  /// if (user != null) {
  ///   print('Current user: ${user.email}');
  /// }
  /// ```
  User? getCurrentUser() {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      return null;
    }
    return _mapFirebaseUserToUser(firebaseUser);
  }

  /// Performs Google Sign-In authentication.
  ///
  /// This method handles the complete Google OAuth flow:
  /// 1. Initiates Google Sign-In dialog
  /// 2. Obtains Google authentication credentials
  /// 3. Creates Firebase credentials from Google tokens
  /// 4. Signs in to Firebase with the credentials
  /// 5. Returns the authenticated user
  ///
  /// Returns a [User] object containing the authenticated user information.
  ///
  /// Throws:
  /// - [Exception] if user cancels the sign-in
  /// - [Exception] if Firebase user is null after sign-in
  /// - [PlatformException] if there's a configuration issue
  /// - Other exceptions for network or authentication failures
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final user = await dataSource.signInWithGoogle();
  ///   print('Signed in: ${user.email}');
  /// } catch (e) {
  ///   print('Sign-in failed: $e');
  /// }
  /// ```
  Future<User> signInWithGoogle() async {
    try {
      debugPrint('[Google Sign-In] 구글 로그인 시작');

      // 구글 로그인 플로우 시작
      debugPrint('[Google Sign-In] GoogleSignIn.signIn() 호출');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      debugPrint(
        '[Google Sign-In] GoogleSignIn.signIn() 완료: ${googleUser != null ? "성공" : "취소"}',
      );

      if (googleUser == null) {
        debugPrint('[Google Sign-In] 사용자가 로그인을 취소했습니다.');
        throw Exception('Googleログインがキャンセルされました。');
      }

      debugPrint(
        '[Google Sign-In] 사용자 정보: ${googleUser.email}, ${googleUser.displayName}',
      );

      // 인증 정보 가져오기
      debugPrint('[Google Sign-In] 인증 정보 가져오기 시작');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      debugPrint('[Google Sign-In] 인증 정보 가져오기 완료');
      debugPrint(
        '[Google Sign-In] AccessToken 존재: ${googleAuth.accessToken != null}',
      );
      debugPrint('[Google Sign-In] IDToken 존재: ${googleAuth.idToken != null}');

      // Firebase 인증 자격 증명 생성
      debugPrint('[Google Sign-In] Firebase 자격 증명 생성 시작');
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      debugPrint('[Google Sign-In] Firebase 자격 증명 생성 완료');

      // Firebase에 로그인
      debugPrint('[Google Sign-In] Firebase 로그인 시작');
      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;
      debugPrint('[Google Sign-In] Firebase 로그인 완료');

      if (firebaseUser == null) {
        debugPrint('[Google Sign-In] Firebase 사용자 정보가 null입니다.');
        throw Exception('ログインに失敗しました。');
      }

      debugPrint(
        '[Google Sign-In] 로그인 성공: ${firebaseUser.uid}, ${firebaseUser.email}',
      );
      final user = _mapFirebaseUserToUser(firebaseUser);
      debugPrint('[Google Sign-In] 사용자 매핑 완료: ${user.id}, ${user.email}');

      return user;
    } on PlatformException catch (e) {
      debugPrint('[Google Sign-In] 플랫폼 에러 발생');
      debugPrint('[Google Sign-In] 에러 코드: ${e.code}');
      debugPrint('[Google Sign-In] 에러 메시지: ${e.message}');
      debugPrint('[Google Sign-In] 에러 상세: ${e.toString()}');

      // 플랫폼 채널 에러인 경우 더 친화적인 메시지 제공
      if (e.code == 'channel-error') {
        debugPrint('[Google Sign-In] 채널 에러 감지 - 설정 파일 확인 필요');
        throw Exception(
          'Googleログインの設定に問題があります。\n'
          'google-services.json (Android) または GoogleService-Info.plist (iOS) ファイルを確認してください。',
        );
      }
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('[Google Sign-In] 일반 에러 발생');
      debugPrint('[Google Sign-In] 에러 타입: ${e.runtimeType}');
      debugPrint('[Google Sign-In] 에러 메시지: $e');
      debugPrint('[Google Sign-In] 스택 트레이스: $stackTrace');

      // 일반적인 에러 메시지
      if (e.toString().contains('channel-error') ||
          e.toString().contains('Unable to establish connection')) {
        debugPrint('[Google Sign-In] 채널 연결 에러 감지');
        throw Exception(
          'Googleログインの設定に問題があります。\n'
          'アプリを再起動するか、設定を確認してください。',
        );
      }
      rethrow;
    }
  }

  /// Performs Apple Sign-In authentication.
  ///
  /// This method handles the complete Apple OAuth flow:
  /// 1. Verifies platform support (iOS/macOS only)
  /// 2. Requests Apple ID credentials with email and name scopes
  /// 3. Creates Firebase OAuth credentials
  /// 4. Signs in to Firebase with the credentials
  /// 5. Updates display name if provided by Apple
  ///
  /// Returns a [User] object containing the authenticated user information.
  ///
  /// Throws:
  /// - [Exception] if platform is not iOS or macOS
  /// - [Exception] if Firebase user is null after sign-in
  /// - [SignInWithAppleAuthorizationException] if user cancels or authorization fails
  ///
  /// Note: Only supported on iOS and macOS platforms.
  ///
  /// Example:
  /// ```dart
  /// if (Platform.isIOS || Platform.isMacOS) {
  ///   try {
  ///     final user = await dataSource.signInWithApple();
  ///     print('Signed in: ${user.email}');
  ///   } catch (e) {
  ///     print('Apple sign-in failed: $e');
  ///   }
  /// }
  /// ```
  Future<User> signInWithApple() async {
    try {
      // 플랫폼 체크 (iOS/macOS만 지원)
      if (!(Platform.isIOS || Platform.isMacOS)) {
        throw Exception('애플 로그인은 iOS와 macOS에서만 지원됩니다.');
      }

      // 애플 로그인 요청
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Firebase 인증 자격 증명 생성
      final oauthCredential = firebase_auth.OAuthProvider("apple.com")
          .credential(
            idToken: appleCredential.identityToken,
            accessToken: appleCredential.authorizationCode,
          );

      // Firebase에 로그인
      final userCredential = await _auth.signInWithCredential(oauthCredential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception('로그인에 실패했습니다.');
      }

      // 애플 로그인 시 이름 정보가 있으면 업데이트
      if (appleCredential.givenName != null ||
          appleCredential.familyName != null) {
        final displayName =
            '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
                .trim();
        if (displayName.isNotEmpty) {
          await firebaseUser.updateDisplayName(displayName);
        }
      }

      return _mapFirebaseUserToUser(firebaseUser);
    } on SignInWithAppleAuthorizationException catch (e) {
      debugPrint('애플 로그인 실패: $e');
      // Error 1000: 시뮬레이터에서 Apple ID 미로그인 또는 시뮬레이터 제한
      if (e.code == AuthorizationErrorCode.unknown) {
        throw Exception(
          'Appleログインに失敗しました。\n'
          'シミュレータの場合は「設定」でApple IDにログインするか、実機でお試しください。',
        );
      }
      // 사용자가 취소한 경우
      if (e.code == AuthorizationErrorCode.canceled) {
        throw Exception('Appleログインがキャンセルされました。');
      }
      rethrow;
    } catch (e) {
      debugPrint('애플 로그인 실패: $e');
      rethrow;
    }
  }

  /// Signs out the current user from Firebase and Google.
  ///
  /// This method signs out from both Firebase Auth and Google Sign-In
  /// to ensure complete logout.
  ///
  /// Throws any exceptions that occur during the sign-out process.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await dataSource.signOut();
  ///   print('Signed out successfully');
  /// } catch (e) {
  ///   print('Sign-out failed: $e');
  /// }
  /// ```
  Future<void> signOut() async {
    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
    } catch (e) {
      debugPrint('로그아웃 실패: $e');
      rethrow;
    }
  }

  /// Deletes the current user's account.
  ///
  /// This method permanently deletes the user's Firebase account and
  /// disconnects from Google Sign-In.
  ///
  /// Throws:
  /// - [Exception] if no user is currently logged in
  /// - [firebase_auth.FirebaseAuthException] with code 'requires-recent-login'
  ///   if the user needs to re-authenticate for security reasons
  ///
  /// Note: For security, this operation may require the user to have
  /// recently signed in. If the user hasn't signed in recently, they will
  /// need to sign out and sign in again before deleting their account.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await dataSource.deleteAccount();
  ///   print('Account deleted successfully');
  /// } catch (e) {
  ///   print('Account deletion failed: $e');
  /// }
  /// ```
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('ログインしているユーザーがいません。');
      }

      // Google 로그인 연결 해제
      await _googleSignIn.signOut();

      // Firebase 계정 삭제
      await user.delete();
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('계정 삭제 실패: $e');
      if (e.code == 'requires-recent-login') {
        throw Exception(
          'セキュリティ上の理由から、再ログインが必要です。\n'
          '一度ログアウトしてから再度ログインした後、アカウント削除をお試しください。',
        );
      }
      rethrow;
    } catch (e) {
      debugPrint('계정 삭제 실패: $e');
      rethrow;
    }
  }

  /// Returns a stream of authentication state changes.
  ///
  /// This stream emits a new [User] object whenever the authentication
  /// state changes (e.g., user signs in, signs out, or token is refreshed).
  ///
  /// Returns a [Stream<User?>] that emits:
  /// - A [User] object when a user is signed in
  /// - null when no user is signed in
  ///
  /// Example:
  /// ```dart
  /// dataSource.authStateChanges().listen((user) {
  ///   if (user != null) {
  ///     print('User signed in: ${user.email}');
  ///   } else {
  ///     print('User signed out');
  ///   }
  /// });
  /// ```
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) {
        return null;
      }
      return _mapFirebaseUserToUser(firebaseUser);
    });
  }

  // ============================================
  // Private Helper Methods
  // ============================================

  /// Converts a Firebase User to the app's User entity.
  ///
  /// This method maps Firebase User properties to the domain User entity,
  /// extracting the provider ID from the user's provider data.
  ///
  /// Parameters:
  /// - [firebaseUser]: The Firebase User object to convert
  ///
  /// Returns a [User] entity with mapped properties including:
  /// - id (from Firebase UID)
  /// - email
  /// - displayName
  /// - photoUrl
  /// - providerId (e.g., 'google.com' or 'apple.com')
  User _mapFirebaseUserToUser(firebase_auth.User firebaseUser) {
    // Provider ID 확인 (구글 또는 애플)
    String? providerId;
    if (firebaseUser.providerData.isNotEmpty) {
      providerId = firebaseUser.providerData.first.providerId;
    }

    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      providerId: providerId,
    );
  }
}
