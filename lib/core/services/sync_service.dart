import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// 데이터 동기화 서비스
/// Firestore와 로컬 데이터 간의 동기화를 관리하고 충돌을 해결합니다.
class SyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  /// 재시도 로직이 포함된 Firestore 작업 실행
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

        // 재시도 가능한 에러인지 확인
        if (!_isRetryableError(e)) {
          rethrow;
        }

        // 마지막 시도가 아니면 대기 후 재시도
        if (attempts < maxRetries) {
          await Future.delayed(_retryDelay * attempts);
          debugPrint('Firestore 작업 재시도: $attempts/$maxRetries');
        }
      } catch (e) {
        // FirebaseException이 아닌 경우 즉시 throw
        rethrow;
      }
    }

    // 모든 재시도 실패
    throw Exception('操作が失敗しました（$maxRetries回試行）: $lastException');
  }

  /// 재시도 가능한 에러인지 확인
  bool _isRetryableError(FirebaseException error) {
    // 네트워크 에러, 타임아웃, 서버 에러 등은 재시도 가능
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

  /// 충돌 해결: 서버 버전 우선 (Last Write Wins)
  Future<Map<String, dynamic>> resolveConflict(
    Map<String, dynamic> localData,
    Map<String, dynamic> serverData,
    DateTime localTimestamp,
    DateTime serverTimestamp,
  ) async {
    // 서버 타임스탬프가 더 최신이면 서버 데이터 사용
    if (serverTimestamp.isAfter(localTimestamp)) {
      return serverData;
    }
    // 로컬 타임스탬프가 더 최신이면 로컬 데이터 사용
    return localData;
  }

  /// 배치 작업 실행 (트랜잭션 사용)
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

  /// 오프라인 상태 확인
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

  /// 오프라인 큐에 작업 추가 (향후 구현)
  Future<void> queueOfflineOperation(
    String operationType,
    Map<String, dynamic> data,
  ) async {
    // 오프라인 작업을 큐에 저장하여 온라인 상태가 되면 실행
    // SharedPreferences나 로컬 데이터베이스에 저장
    debugPrint('オフライン操作をキューに追加: $operationType');
  }
}

