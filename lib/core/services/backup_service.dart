import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/fridge/data/datasources/fridge_firestore_datasource.dart';
import '../../features/stock/data/datasources/stock_firestore_datasource.dart';
import '../../features/home/data/datasources/shopping_list_local_datasource.dart';
import '../../features/settings/data/datasources/category_local_datasource.dart';
import '../../features/fridge/data/models/fridge_item_model.dart';
import '../../features/stock/data/models/stock_item_model.dart';
import '../../features/home/data/models/shopping_list_item_model.dart';
import '../../features/settings/data/models/category_model.dart';

class BackupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _backupCollection = 'backups';
  final FridgeFirestoreDataSource _fridgeDataSource = FridgeFirestoreDataSource();
  final StockFirestoreDataSource _stockDataSource = StockFirestoreDataSource();
  final ShoppingListLocalDataSource _shoppingListDataSource = ShoppingListLocalDataSource();
  final CategoryLocalDataSource _categoryDataSource = CategoryLocalDataSource();

  /// 현재 사용자 ID 가져오기
  String? _getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  /// 사용자별 백업 컬렉션 경로 가져오기
  CollectionReference _getUserBackupCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection(_backupCollection);
  }

  /// 모든 데이터를 Firestore에 백업
  Future<void> backupAllData() async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      throw Exception('사용자가 로그인하지 않았습니다.');
    }

    try {
      // 모든 데이터 수집
      final fridgeItems = await _fridgeDataSource.getFridgeItems();
      final stockItems = await _stockDataSource.getStockItems();
      final shoppingListItems = await _shoppingListDataSource.getItems();
      final categories = await _categoryDataSource.getCategories();

      // 백업 데이터 구성
      final backupData = {
        'userId': userId,
        'fridgeItems': fridgeItems.map((item) => item.toJson()).toList(),
        'stockItems': stockItems.map((item) => item.toJson()).toList(),
        'shoppingListItems': shoppingListItems.map((item) => item.toJson()).toList(),
        'categories': categories.map((item) => item.toJson()).toList(),
        'backupDate': FieldValue.serverTimestamp(),
        'version': '1.0.0',
      };

      // Firestore에 백업 저장 (사용자별 서브컬렉션)
      final backupId = DateTime.now().millisecondsSinceEpoch.toString();
      await _getUserBackupCollection(userId)
          .doc(backupId)
          .set(backupData);

      // SharedPreferences에도 백업 메타데이터 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_backup_date', DateTime.now().toIso8601String());
    } catch (e) {
      throw Exception('バックアップに失敗しました: $e');
    }
  }

  /// Firestore에서 백업 데이터를 복원
  Future<void> restoreAllData() async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      throw Exception('사용자가 로그인하지 않았습니다.');
    }

    try {
      // Firestore에서 가장 최근 백업 데이터 가져오기
      final backupSnapshot = await _getUserBackupCollection(userId)
          .orderBy('backupDate', descending: true)
          .limit(1)
          .get();

      if (backupSnapshot.docs.isEmpty) {
        throw Exception('バックアップデータが見つかりません');
      }

      final backupDoc = backupSnapshot.docs.first;

      if (!backupDoc.exists) {
        throw Exception('バックアップデータが見つかりません');
      }

      final backupData = backupDoc.data() as Map<String, dynamic>;

      // 냉장고 아이템 복원
      if (backupData['fridgeItems'] != null) {
        final fridgeItemsJson = backupData['fridgeItems'] as List<dynamic>;
        final fridgeItems = fridgeItemsJson
            .map((json) => FridgeItemModel.fromJson(json as Map<String, dynamic>))
            .toList();

        // 기존 데이터 삭제 후 복원
        final existingItems = await _fridgeDataSource.getFridgeItems();
        for (final item in existingItems) {
          await _fridgeDataSource.deleteFridgeItem(item.id);
        }

        for (final item in fridgeItems) {
          await _fridgeDataSource.addFridgeItem(item);
        }
      }

      // 재고 아이템 복원
      if (backupData['stockItems'] != null) {
        final stockItemsJson = backupData['stockItems'] as List<dynamic>;
        final stockItems = stockItemsJson
            .map((json) => StockItemModel.fromJson(json as Map<String, dynamic>))
            .toList();

        // 기존 데이터 삭제 후 복원
        final existingItems = await _stockDataSource.getStockItems();
        for (final item in existingItems) {
          await _stockDataSource.deleteStockItem(item.id);
        }

        for (final item in stockItems) {
          await _stockDataSource.addStockItem(item);
        }
      }

      // 쇼핑 리스트 복원
      if (backupData['shoppingListItems'] != null) {
        final shoppingListItemsJson = backupData['shoppingListItems'] as List<dynamic>;
        final shoppingListItems = shoppingListItemsJson
            .map((json) => ShoppingListItemModel.fromJson(json as Map<String, dynamic>))
            .toList();

        await _shoppingListDataSource.saveItems(shoppingListItems);
      }

      // 카테고리 복원
      if (backupData['categories'] != null) {
        final categoriesJson = backupData['categories'] as List<dynamic>;
        final categories = categoriesJson
            .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
            .toList();

        await _categoryDataSource.saveCategories(categories);
      }

      // 복원 메타데이터 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_restore_date', DateTime.now().toIso8601String());
    } catch (e) {
      throw Exception('復元に失敗しました: $e');
    }
  }

  /// 마지막 백업 날짜 가져오기
  Future<DateTime?> getLastBackupDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateString = prefs.getString('last_backup_date');
      if (dateString != null) {
        return DateTime.parse(dateString);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 백업 데이터 존재 여부 확인
  Future<bool> hasBackupData() async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      return false;
    }

    try {
      final backupSnapshot = await _getUserBackupCollection(userId)
          .limit(1)
          .get();
      return backupSnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

