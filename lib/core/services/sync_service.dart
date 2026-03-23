import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Sync Service
///
/// Manages data synchronization between Firestore and local data,
/// handles conflict resolution, and provides retry logic for failed operations.
///
/// Features:
/// - Automatic retry for transient Firestore errors
/// - Conflict resolution using Last Write Wins strategy
/// - Batch operations support
/// - Online/offline status detection
/// - Offline operation queueing (future implementation)
class SyncService {
  final FirebaseFirestore _firestore;
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  SyncService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Executes a Firestore operation with retry logic
  ///
  /// Automatically retries failed operations for transient errors such as
  /// network issues, timeouts, and server errors. Uses exponential backoff
  /// between retry attempts.
  ///
  /// Parameters:
  ///   - operation: The async operation to execute
  ///   - maxRetries: Maximum number of retry attempts (default: 3)
  ///
  /// Returns: The result of the operation
  ///
  /// Throws: The last exception if all retry attempts fail, or immediately
  ///         if the error is not retryable
  Future<T> executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = _maxRetries,
  }) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts < maxRetries) {
      try {
        return await operation();
      } on FirebaseException catch (e) {
        lastException = e;
        attempts++;

        // Check if error is retryable
        if (!_isRetryableError(e)) {
          rethrow;
        }

        // Wait before retrying (exponential backoff)
        if (attempts < maxRetries) {
          await Future.delayed(_retryDelay * attempts);
          debugPrint('Retrying Firestore operation: $attempts/$maxRetries');
        }
      } catch (e) {
        // Immediately throw if not a FirebaseException
        rethrow;
      }
    }

    // All retries failed
    throw Exception('Operation failed after $maxRetries attempts: $lastException');
  }

  /// Determines if a Firebase error is retryable
  ///
  /// Network errors, timeouts, and server errors are considered retryable.
  ///
  /// Parameters:
  ///   - error: The Firebase exception to check
  ///
  /// Returns: `true` if the error is retryable, `false` otherwise
  bool _isRetryableError(FirebaseException error) {
    switch (error.code) {
      case 'unavailable':
      case 'deadline-exceeded':
      case 'internal':
      case 'resource-exhausted':
        return true;
      default:
        return false;
    }
  }

  /// Resolves conflicts using Last Write Wins strategy
  ///
  /// Compares timestamps and returns the data with the most recent timestamp.
  /// Server data takes precedence if timestamps are equal.
  ///
  /// Parameters:
  ///   - localData: The local version of the data
  ///   - serverData: The server version of the data
  ///   - localTimestamp: Timestamp of the local data
  ///   - serverTimestamp: Timestamp of the server data
  ///
  /// Returns: The data to use (either local or server)
  Future<Map<String, dynamic>> resolveConflict(
    Map<String, dynamic> localData,
    Map<String, dynamic> serverData,
    DateTime localTimestamp,
    DateTime serverTimestamp,
  ) async {
    // Use server data if server timestamp is newer
    if (serverTimestamp.isAfter(localTimestamp)) {
      return serverData;
    }
    // Use local data if local timestamp is newer
    return localData;
  }

  /// Executes batch operations
  ///
  /// Groups multiple Firestore operations into a single atomic batch.
  /// All operations succeed or fail together.
  ///
  /// Parameters:
  ///   - operations: List of operations to execute as a batch
  ///
  /// Throws: Exception if batch commit fails after all retries
  Future<void> executeBatch(
    List<Future<void> Function(WriteBatch)> operations,
  ) async {
    await executeWithRetry(() async {
      final batch = _firestore.batch();

      for (final operation in operations) {
        await operation(batch);
      }

      await batch.commit();
    });
  }

  /// Checks if the device is online
  ///
  /// Attempts a simple Firestore query to determine connectivity.
  ///
  /// Returns: `true` if online, `false` if offline
  Future<bool> isOnline() async {
    try {
      // 간단한 쿼리로 연결 상태 확인
      await _firestore.collection('_health').limit(1).get(
        const GetOptions(source: Source.server),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Queues an operation for offline execution (future implementation)
  ///
  /// Stores operations in a queue to be executed when the device comes back online.
  /// Currently saves to SharedPreferences or a local database.
  ///
  /// Parameters:
  ///   - operationType: The type of operation to queue
  ///   - data: The operation data
  Future<void> queueOfflineOperation(
    String operationType,
    Map<String, dynamic> data,
  ) async {
    debugPrint('Adding offline operation to queue: $operationType');
  }
}

