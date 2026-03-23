import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/app_keys.dart';
import '../../../../core/services/sync_service.dart';
import '../models/fridge_item_model.dart';
import 'fridge_local_datasource.dart';

/// Firestore data source for fridge item operations.
///
/// This class handles all Firestore interactions for fridge items, supporting
/// both individual user storage and household-shared storage models.
///
/// ## Storage Architecture:
/// The datasource supports two storage patterns:
/// - **Personal storage**: `users/{userId}/fridge_items/{itemId}` (legacy)
/// - **Household storage**: `households/{householdId}/fridge_items/{itemId}` (current)
///
/// When a user joins a household, items are automatically migrated to the
/// household's shared storage and tracked with `addedBy` and `lastModifiedBy` fields.
///
/// ## Offline Support:
/// Uses Firestore's cache-first strategy for better offline performance:
/// 1. Attempts to read from local cache first
/// 2. Falls back to server if cache is empty
/// 3. Retry logic via [SyncService] for resilient network operations
///
/// ## Firestore Structure:
/// ```
/// households/{householdId}/fridge_items/{itemId}
///   - name, quantity, category, expiryDate, isFrozen
///   - addedBy: userId (household mode only)
///   - lastModifiedBy: userId (household mode only)
///   - createdAt, updatedAt
///
/// users/{userId}/fridge_items/{itemId}  (legacy personal storage)
///   - name, quantity, category, expiryDate, isFrozen
///   - createdAt, updatedAt
/// ```
class FridgeFirestoreDataSource implements FridgeDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = AppKeys.fridgeCollection;
  final SyncService _syncService = SyncService();

  // ============================================
  // Helper Methods - User & Collection Access
  // ============================================

  /// Gets the currently authenticated user's ID.
  ///
  /// Returns `null` if no user is logged in.
  String? _getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  /// Gets the current user's household ID.
  ///
  /// Returns `null` if:
  /// - No user is logged in
  /// - User has no household association
  Future<String?> _getCurrentHouseholdId() async {
    final userId = _getCurrentUserId();
    if (userId == null) return null;

    final userDoc = await _firestore.collection('users').doc(userId).get();
    return userDoc.data()?['householdId'] as String?;
  }

  /// Gets the collection reference for household-based storage.
  ///
  /// Returns: `households/{householdId}/fridge_items`
  CollectionReference _getHouseholdCollection(String householdId) {
    return _firestore.collection('households').doc(householdId).collection(_collection);
  }

  /// Gets the collection reference for personal user storage (legacy).
  ///
  /// Returns: `users/{userId}/fridge_items`
  ///
  /// This is maintained for backward compatibility with items
  /// created before household migration.
  CollectionReference _getUserCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection(_collection);
  }

  // ============================================
  // CRUD Operations
  // ============================================

  /// Retrieves all fridge items for the current user or household.
  ///
  /// Uses cache-first strategy for better offline performance:
  /// 1. Attempts to read from local Firestore cache
  /// 2. Falls back to server if cache is empty
  ///
  /// The data source automatically determines whether to read from:
  /// - Household collection (if user is in a household)
  /// - Personal collection (if user has no household)
  ///
  /// Throws an [Exception] if no user is logged in.
  @override
  Future<List<FridgeItemModel>> getFridgeItems() async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      throw Exception('User is not logged in.');
    }

    final householdId = await _getCurrentHouseholdId();

    return await _syncService.executeWithRetry(() async {
      // Use household collection if available, otherwise personal collection
      final collection = householdId != null
          ? _getHouseholdCollection(householdId)
          : _getUserCollection(userId);

      // Offline-first: Try cache first
      final snapshot = await collection
          .get(const GetOptions(source: Source.cache));

      // If cache is empty, fetch from server
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

  /// Retrieves fridge items with pagination support.
  ///
  /// Useful for large datasets to load items incrementally.
  /// Items are ordered by creation date (newest first).
  ///
  /// Parameters:
  /// - [limit]: Maximum number of items to return (default: 20)
  /// - [startAfter]: Document snapshot to start after (for pagination)
  ///
  /// Returns a list of [FridgeItemModel] objects limited by the specified count.
  ///
  /// Throws an [Exception] if no user is logged in.
  ///
  /// Example:
  /// ```dart
  /// // First page
  /// final firstPage = await getFridgeItemsPaginated(limit: 20);
  ///
  /// // Next page
  /// final lastDoc = firstPage.last.documentSnapshot;
  /// final nextPage = await getFridgeItemsPaginated(
  ///   limit: 20,
  ///   startAfter: lastDoc,
  /// );
  /// ```
  Future<List<FridgeItemModel>> getFridgeItemsPaginated({
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      throw Exception('User is not logged in.');
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

  /// Adds a new fridge item to Firestore.
  ///
  /// In household mode, the item is tagged with:
  /// - `addedBy`: Current user's ID
  /// - `lastModifiedBy`: Current user's ID
  ///
  /// These fields help track item ownership and modification history
  /// in shared household storage.
  ///
  /// Parameters:
  /// - [item]: The fridge item to add
  ///
  /// Throws:
  /// - [Exception] if no user is logged in
  /// - [Exception] with permission error message if Firestore security rules deny access
  @override
  Future<void> addFridgeItem(FridgeItemModel item) async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      debugPrint('[FridgeFirestoreDataSource] User is not logged in.');
      throw Exception('Login required. Please log in and try again.');
    }

    final householdId = await _getCurrentHouseholdId();

    debugPrint('[FridgeFirestoreDataSource] Adding fridge item: userId=$userId, householdId=$householdId, itemId=${item.id}');

    try {
      await _syncService.executeWithRetry(() async {
        final collection = householdId != null
            ? _getHouseholdCollection(householdId)
            : _getUserCollection(userId);

        final json = item.toJson();
        // Track who added the item (household mode only)
        if (householdId != null) {
          json['addedBy'] = userId;
          json['lastModifiedBy'] = userId;
        }

        await collection.doc(item.id).set(json);
      });
      debugPrint('[FridgeFirestoreDataSource] Fridge item added successfully');
    } catch (e) {
      debugPrint('[FridgeFirestoreDataSource] Failed to add fridge item: $e');
      debugPrint('[FridgeFirestoreDataSource] Error type: ${e.runtimeType}');

      // Provide user-friendly message for permission errors
      if (e.toString().contains('permission-denied')) {
        throw Exception(
          'Failed to save item.\n'
          'Please check Firestore security rules in Firebase Console.\n'
          'Verify the rules are correctly configured and click Publish.',
        );
      }
      rethrow;
    }
  }

  /// Updates an existing fridge item in Firestore.
  ///
  /// In household mode, updates the `lastModifiedBy` field to track
  /// the most recent editor.
  ///
  /// Special handling:
  /// - If `targetQuantity` is `null`, the field is deleted from Firestore
  ///   rather than stored as null (Firestore best practice)
  ///
  /// Parameters:
  /// - [item]: The fridge item with updated values
  ///
  /// Throws an [Exception] if no user is logged in.
  @override
  Future<void> updateFridgeItem(FridgeItemModel item) async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      throw Exception('User is not logged in.');
    }

    final householdId = await _getCurrentHouseholdId();

    await _syncService.executeWithRetry(() async {
      final collection = householdId != null
          ? _getHouseholdCollection(householdId)
          : _getUserCollection(userId);

      final json = item.toJson();
      // Delete targetQuantity field if null (Firestore best practice)
      if (json['targetQuantity'] == null) {
        json['targetQuantity'] = FieldValue.delete();
      }
      // Track who last modified the item (household mode only)
      if (householdId != null) {
        json['lastModifiedBy'] = userId;
      }

      await collection.doc(item.id).update(json);
    });
  }

  /// Deletes a fridge item from Firestore.
  ///
  /// Permanently removes the item document from the appropriate collection
  /// (household or personal, based on current user state).
  ///
  /// Parameters:
  /// - [id]: The ID of the fridge item to delete
  ///
  /// Throws an [Exception] if no user is logged in.
  @override
  Future<void> deleteFridgeItem(String id) async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      throw Exception('User is not logged in.');
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

