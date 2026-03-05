import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/app_keys.dart';
import '../../../../core/services/sync_service.dart';
import '../models/fridge_item_model.dart';
import 'fridge_local_datasource.dart';

class FridgeFirestoreDataSource implements FridgeDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = AppKeys.fridgeCollection;
  final SyncService _syncService = SyncService();

  /// 현재 사용자 ID 가져오기
  String? _getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  /// 현재 사용자의 householdId 가져오기
  Future<String?> _getCurrentHouseholdId() async {
    final userId = _getCurrentUserId();
    if (userId == null) return null;

    final userDoc = await _firestore.collection('users').doc(userId).get();
    return userDoc.data()?['householdId'] as String?;
  }

  /// householdId 기반 컬렉션 경로 가져오기
  CollectionReference _getHouseholdCollection(String householdId) {
    return _firestore.collection('households').doc(householdId).collection(_collection);
  }

  /// 사용자별 컬렉션 경로 가져오기 (레거시 - 마이그레이션 전 데이터용)
  CollectionReference _getUserCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection(_collection);
  }

  @override
  Future<List<FridgeItemModel>> getFridgeItems() async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      throw Exception('사용자가 로그인하지 않았습니다.');
    }

    final householdId = await _getCurrentHouseholdId();

    return await _syncService.executeWithRetry(() async {
      // householdId가 있으면 household 컬렉션에서 읽기
      final collection = householdId != null
          ? _getHouseholdCollection(householdId)
          : _getUserCollection(userId);

      // 오프라인 우선: 캐시에서 먼저 읽기 시도
      final snapshot = await collection
          .get(const GetOptions(source: Source.cache));

      // 캐시에 데이터가 없으면 서버에서 가져오기
      if (snapshot.docs.isEmpty) {
        final serverSnapshot = await collection
            .get(const GetOptions(source: Source.server));
        return serverSnapshot.docs
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return FridgeItemModel.fromJson({
                'id': doc.id,
                ...data,
              });
            })
            .toList();
      }

      return snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return FridgeItemModel.fromJson({
              'id': doc.id,
              ...data,
            });
          })
          .toList();
    });
  }

  /// 페이지네이션을 사용한 아이템 가져오기
  Future<List<FridgeItemModel>> getFridgeItemsPaginated({
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      throw Exception('사용자가 로그인하지 않았습니다.');
    }

    final householdId = await _getCurrentHouseholdId();

    return await _syncService.executeWithRetry(() async {
      final collection = householdId != null
          ? _getHouseholdCollection(householdId)
          : _getUserCollection(userId);

      Query query = collection
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get(const GetOptions(source: Source.cache));

      if (snapshot.docs.isEmpty) {
        final serverSnapshot = await query.get(const GetOptions(source: Source.server));
        return serverSnapshot.docs
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return FridgeItemModel.fromJson({
                'id': doc.id,
                ...data,
              });
            })
            .toList();
      }

      return snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return FridgeItemModel.fromJson({
              'id': doc.id,
              ...data,
            });
          })
          .toList();
    });
  }

  @override
  Future<void> addFridgeItem(FridgeItemModel item) async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      debugPrint('[FridgeFirestoreDataSource] 사용자가 로그인하지 않았습니다.');
      throw Exception('ログインが必要です。ログインしてからもう一度お試しください。');
    }

    final householdId = await _getCurrentHouseholdId();

    debugPrint('[FridgeFirestoreDataSource] 냉장고 아이템 추가 시작: userId=$userId, householdId=$householdId, itemId=${item.id}');

    try {
      await _syncService.executeWithRetry(() async {
        final collection = householdId != null
            ? _getHouseholdCollection(householdId)
            : _getUserCollection(userId);

        final json = item.toJson();
        // 추가한 사용자 정보 기록
        if (householdId != null) {
          json['addedBy'] = userId;
          json['lastModifiedBy'] = userId;
        }

        await collection.doc(item.id).set(json);
      });
      debugPrint('[FridgeFirestoreDataSource] 냉장고 아이템 추가 성공');
    } catch (e) {
      debugPrint('[FridgeFirestoreDataSource] 냉장고 아이템 추가 실패: $e');
      debugPrint('[FridgeFirestoreDataSource] 에러 타입: ${e.runtimeType}');

      // 권한 오류인 경우 더 친화적인 메시지 제공
      if (e.toString().contains('permission-denied')) {
        throw Exception(
          '保存に失敗しました。\n'
          'Firebase ConsoleでFirestoreのセキュリティルールを確認してください。\n'
          'ルールが正しく設定されているか確認し、公開ボタンをクリックしてください。',
        );
      }
      rethrow;
    }
  }

  @override
  Future<void> updateFridgeItem(FridgeItemModel item) async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      throw Exception('사용자가 로그인하지 않았습니다.');
    }

    final householdId = await _getCurrentHouseholdId();

    await _syncService.executeWithRetry(() async {
      final collection = householdId != null
          ? _getHouseholdCollection(householdId)
          : _getUserCollection(userId);

      final json = item.toJson();
      // targetQuantity가 null인 경우 Firestore에서 필드 삭제
      if (json['targetQuantity'] == null) {
        json['targetQuantity'] = FieldValue.delete();
      }
      // 수정한 사용자 정보 기록
      if (householdId != null) {
        json['lastModifiedBy'] = userId;
      }

      await collection.doc(item.id).update(json);
    });
  }

  @override
  Future<void> deleteFridgeItem(String id) async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      throw Exception('사용자가 로그인하지 않았습니다.');
    }

    final householdId = await _getCurrentHouseholdId();

    await _syncService.executeWithRetry(() async {
      final collection = householdId != null
          ? _getHouseholdCollection(householdId)
          : _getUserCollection(userId);

      await collection.doc(id).delete();
    });
  }
}

