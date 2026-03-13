import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/backup_service.dart';

/// 백업 서비스 프로바이더
final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService();
});
