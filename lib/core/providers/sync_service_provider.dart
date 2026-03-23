import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/sync_service.dart';

/// Sync Service Provider
///
/// Provides the sync service instance for dependency injection.
/// This provider creates and manages the SyncService for handling
/// data synchronization and conflict resolution throughout the application.
final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService();
});
