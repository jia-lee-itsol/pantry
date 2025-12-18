import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../core/firebase/firebase_initializer.dart';
import '../core/services/permission_service.dart';
import '../core/services/notification_scheduling_service.dart';
import 'app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 환경 변수 로드
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('환경 변수 로드 실패: $e');
  }

  await FirebaseInitializer.initialize();

  // 권한 요청 (비동기로 처리하므로 앱 시작을 막지 않음)
  // 에러가 발생해도 앱 시작을 막지 않도록 try-catch 처리
  try {
    await PermissionService.requestAllPermissions();
  } catch (e) {
    // MissingPluginException 등 권한 플러그인 에러는 무시하고 앱 계속 실행
    debugPrint('권한 요청 실패 (무시됨): $e');
  }

  // 알림 서비스 초기화
  try {
    final notificationService = NotificationSchedulingService();
    await notificationService.initialize();
  } catch (e) {
    debugPrint('알림 서비스 초기화 실패 (무시됨): $e');
  }

  runApp(const ProviderScope(child: App()));
}
