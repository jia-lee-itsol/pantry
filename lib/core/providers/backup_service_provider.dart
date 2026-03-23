import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/backup_service.dart';

/// Backup Service Provider
///
/// Provides the backup service instance for dependency injection.
/// This provider creates and manages the BackupService for handling
/// data backup and restoration operations throughout the application.
final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService();
});
