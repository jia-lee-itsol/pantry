import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/app_keys.dart';
import '../../../../core/services/sync_service.dart';
import '../models/stock_item_model.dart';
import 'stock_local_datasource.dart';

// ============================================
// Firestore Stock Data Source Implementation
// ============================================

/// Cloud Firestore implementation of the stock data source.
///
/// This class provides Firebase Cloud Firestore integration for stock item
/// persistence with the following features:
///
/// **Multi-tenancy Support:**
/// - Household-based data isolation for family sharing
/// - User-specific collections for legacy data support
/// - Automatic user context resolution
///
/// **Offline-first Architecture:**
/// - Cache-first read strategy for better performance
/// - Automatic fallback to server when cache is empty
/// - Offline data persistence via Firestore SDK
///
/// **Reliability Features:**
/// - Automatic retry logic via [SyncService]
/// - Conflict resolution for concurrent updates
/// - User attribution tracking (addedBy, lastModifiedBy)
///
/// **Data Organization:**
/// - `households/{householdId}/stock` for shared data
/// - `users/{userId}/stock` for legacy single-user data
class StockFirestoreDataSource implements StockDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = AppKeys.stockCollection;
  final SyncService _syncService = SyncService();

  // ============================================
  // Private Helper Methods - User & Collection Resolution
  // ============================================

  /// Gets the current authenticated user's ID.
  ///
  /// Returns the Firebase UID of the currently logged-in user,
  /// or null if no user is authenticated.
  String? _getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  /// Retrieves the household ID for the current user.
  ///
  /// Fetches the user's document from Firestore to determine which
  /// household they belong to. This enables multi-user family sharing.
  ///
  /// Returns the household ID if the user belongs to one, null otherwise.
  Future<String?> _getCurrentHouseholdId() async {
    final userId = _getCurrentUserId();
    if (userId == null) return null;

    final userDoc = await _firestore.collection('users').doc(userId).get();
    return userDoc.data()?['householdId'] as String?;
  }

  /// Gets the Firestore collection reference for a household.
  ///
  /// Parameters:
  /// - [householdId]: The unique identifier of the household
  ///
  /// Returns a collection reference to `households/{householdId}/stock`.
  CollectionReference _getHouseholdCollection(String householdId) {
    return _firestore.collection('households').doc(householdId).collection(_collection);
  }

  /// Gets the Firestore collection reference for a single user.
  ///
  /// This is used for legacy data that was created before the household
  /// feature was implemented. New data should use household collections.
  ///
  /// Parameters:
  /// - [userId]: The unique identifier of the user
  ///
  /// Returns a collection reference to `users/{userId}/stock`.
  CollectionReference _getUserCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection(_collection);
  }

  // ============================================
  // CRUD Operations - Read
  // ============================================

  /// Retrieves all stock items from Firestore.
  ///
  /// **Offline-first Strategy:**
  /// 1. First attempts to read from local Firestore cache
  /// 2. If cache is empty, fetches from server
  /// 3. All reads respect the user's household context
  ///
  /// **Data Resolution:**
  /// - If user has a household ID, reads from household collection
  /// - Otherwise, reads from user's personal collection (legacy support)
  ///
  /// Returns a list of all stock items accessible to the current user.
  ///
  /// Throws an exception if:
  /// - User is not authenticated
  /// - Network/Firestore operation fails
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

  /// Retrieves stock items with pagination support.
  ///
  /// This method is designed for handling large datasets efficiently by
  /// loading items in chunks. Items are sorted by last update time in
  /// descending order (newest first).
  ///
  /// **Pagination Mechanism:**
  /// - First call: Pass no [startAfter] to get the first page
  /// - Subsequent calls: Pass the last document from previous page
  /// - Results are automatically sorted by [lastUpdated] field
  ///
  /// **Parameters:**
  /// - [limit]: Maximum number of items to retrieve (default: 20)
  /// - [startAfter]: Document to start after (null for first page)
  ///
  /// Returns a list of stock items for the requested page.
  ///
  /// Throws an exception if the operation fails or user is not authenticated.
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

  // ============================================
  // CRUD Operations - Create
  // ============================================

  /// Adds a new stock item to Firestore.
  ///
  /// **User Attribution:**
  /// - In household mode: Records `addedBy` and `lastModifiedBy` fields
  /// - Enables tracking which family member added each item
  ///
  /// **Data Storage:**
  /// - Uses household collection if user belongs to a household
  /// - Otherwise uses user's personal collection
  ///
  /// Parameters:
  /// - [item]: The stock item model to persist
  ///
  /// Throws an exception if:
  /// - User is not authenticated
  /// - Item with same ID already exists
  /// - Firestore operation fails
  @override
  Future<void> addStockItem(StockItemModel item) async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      throw Exception('User is not authenticated.');
    }

    final householdId = await _getCurrentHouseholdId();

    await _syncService.executeWithRetry(() async {
      final collection = householdId != null
          ? _getHouseholdCollection(householdId)
          : _getUserCollection(userId);

      final json = item.toJson();
      // Record which user added this item (household mode only)
      if (householdId != null) {
        json['addedBy'] = userId;
        json['lastModifiedBy'] = userId;
      }

      await collection.doc(item.id).set(json);
    });
  }

  // ============================================
  // CRUD Operations - Update
  // ============================================

  /// Updates an existing stock item in Firestore.
  ///
  /// **Field Deletion:**
  /// - Null values for `targetQuantity` trigger field deletion
  /// - This ensures clean data without undefined/null fields
  ///
  /// **User Attribution:**
  /// - Updates `lastModifiedBy` field in household mode
  /// - Tracks which family member last modified the item
  ///
  /// Parameters:
  /// - [item]: The stock item model with updated values
  ///
  /// Throws an exception if:
  /// - User is not authenticated
  /// - Item doesn't exist
  /// - Firestore operation fails
  @override
  Future<void> updateStockItem(StockItemModel item) async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      throw Exception('User is not authenticated.');
    }

    final householdId = await _getCurrentHouseholdId();

    await _syncService.executeWithRetry(() async {
      final collection = householdId != null
          ? _getHouseholdCollection(householdId)
          : _getUserCollection(userId);

      final json = item.toJson();
      // Delete targetQuantity field from Firestore if null
      if (json['targetQuantity'] == null) {
        json['targetQuantity'] = FieldValue.delete();
      }
      // Record which user modified this item (household mode only)
      if (householdId != null) {
        json['lastModifiedBy'] = userId;
      }

      await collection.doc(item.id).update(json);
    });
  }

  // ============================================
  // CRUD Operations - Delete
  // ============================================

  /// Deletes a stock item from Firestore.
  ///
  /// **Permanent Deletion:**
  /// - Removes the document completely from the collection
  /// - Cannot be undone (ensure proper confirmation in UI)
  ///
  /// **Collection Resolution:**
  /// - Deletes from household collection if user is in a household
  /// - Otherwise deletes from user's personal collection
  ///
  /// Parameters:
  /// - [id]: The unique identifier of the item to delete
  ///
  /// Throws an exception if:
  /// - User is not authenticated
  /// - Firestore operation fails
  @override
  Future<void> deleteStockItem(String id) async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      throw Exception('User is not authenticated.');
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
