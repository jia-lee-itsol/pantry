import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/app_keys.dart';
import '../../../../core/services/sync_service.dart';
import '../models/stock_item_model.dart';
import 'stock_local_datasource.dart';

class StockFirestoreDataSource implements StockDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = AppKeys.stockCollection;
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

  /// 모든 재고 아이템을 가져옵니다.
  ///
  /// 오프라인 우선 전략을 사용하여 캐시에서 먼저 읽기를 시도하고,
  /// 캐시가 비어있으면 서버에서 가져옵니다.
  /// SyncService를 통해 재시도 로직 및 충돌 해결을 처리합니다.
  @override
  Future<List<StockItemModel>> getStockItems() async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      throw Exception('사용자가 로그인하지 않았습니다.');
    }

    final householdId = await _getCurrentHouseholdId();

    return await _syncService.executeWithRetry(() async {
      final collection = householdId != null
          ? _getHouseholdCollection(householdId)
          : _getUserCollection(userId);

      // 오프라인 우선: 캐시에서 먼저 읽기 시도
      final snapshot = await collection.get(const GetOptions(source: Source.cache));

      // 캐시에 데이터가 없으면 서버에서 가져오기
      if (snapshot.docs.isEmpty) {
        final serverSnapshot = await collection.get(const GetOptions(source: Source.server));
        return serverSnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return StockItemModel.fromJson({'id': doc.id, ...data});
        }).toList();
      }

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return StockItemModel.fromJson({'id': doc.id, ...data});
      }).toList();
    });
  }

  /// 페이지네이션을 사용한 아이템 가져오기
  ///
  /// 대량 데이터 처리를 위한 페이지네이션 지원 메서드입니다.
  /// [limit]만큼의 아이템을 가져오며, [startAfter]를 지정하면 해당 문서 이후의 데이터를 가져옵니다.
  /// 마지막 업데이트 시간 기준으로 내림차순 정렬됩니다.
  ///
  /// 파라미터:
  /// - [limit]: 가져올 최대 아이템 수 (기본값: 20)
  /// - [startAfter]: 페이지네이션 시작점 문서 (null이면 처음부터)
  Future<List<StockItemModel>> getStockItemsPaginated({
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
          .orderBy('lastUpdated', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get(const GetOptions(source: Source.cache));

      if (snapshot.docs.isEmpty) {
        final serverSnapshot = await query.get(
          const GetOptions(source: Source.server),
        );
        return serverSnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return StockItemModel.fromJson({'id': doc.id, ...data});
        }).toList();
      }

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return StockItemModel.fromJson({'id': doc.id, ...data});
      }).toList();
    });
  }

  @override
  Future<void> addStockItem(StockItemModel item) async {
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
      // 추가한 사용자 정보 기록
      if (householdId != null) {
        json['addedBy'] = userId;
        json['lastModifiedBy'] = userId;
      }

      await collection.doc(item.id).set(json);
    });
  }

  @override
  Future<void> updateStockItem(StockItemModel item) async {
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
  Future<void> deleteStockItem(String id) async {
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
