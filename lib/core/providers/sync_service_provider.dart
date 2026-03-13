import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/sync_service.dart';

/// 동기화 서비스 프로바이더
final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService();
});
