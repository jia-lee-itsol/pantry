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

/// Backup Service
///
/// Manages data backup and restoration to/from Firestore.
/// This service backs up all user data including fridge items, stock items,
/// shopping lists, and categories to Firestore, allowing users to restore
/// their data on different devices or after reinstalling the app.
///
/// Features:
/// - Complete data backup to Firestore
/// - Versioned backup system
/// - Per-user backup isolation
/// - Backup metadata tracking
/// - Full data restoration
class BackupService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  static const String _backupCollection = 'backups';
  final FridgeFirestoreDataSource _fridgeDataSource;
  final StockFirestoreDataSource _stockDataSource;
  final ShoppingListLocalDataSource _shoppingListDataSource;
  final CategoryLocalDataSource _categoryDataSource;

  BackupService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FridgeFirestoreDataSource? fridgeDataSource,
    StockFirestoreDataSource? stockDataSource,
    ShoppingListLocalDataSource? shoppingListDataSource,
    CategoryLocalDataSource? categoryDataSource,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _fridgeDataSource = fridgeDataSource ?? FridgeFirestoreDataSource(),
        _stockDataSource = stockDataSource ?? StockFirestoreDataSource(),
        _shoppingListDataSource = shoppingListDataSource ?? ShoppingListLocalDataSource(),
        _categoryDataSource = categoryDataSource ?? CategoryLocalDataSource();

  /// Gets the current user ID
  ///
  /// Returns: The current user's UID, or null if not authenticated
  String? _getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  /// Gets the user-specific backup collection
  ///
  /// Each user has their own backup subcollection under their user document.
  ///
  /// Parameters:
  ///   - userId: The user's UID
  ///
  /// Returns: Reference to the user's backup collection
  CollectionReference _getUserBackupCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection(_backupCollection);
  }

  /// Backs up all data to Firestore
  ///
  /// Creates a complete backup of all user data including:
  /// - Fridge items
  /// - Stock items
  /// - Shopping list items
  /// - Custom categories
  ///
  /// The backup is stored in Firestore under the user's backup collection
  /// with a timestamp-based ID. Backup metadata is also saved to SharedPreferences.
  ///
  /// Throws: Exception if the user is not authenticated or backup fails
  Future<void> backupAllData() async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      throw Exception('User is not logged in.');
    }

    try {
      // Collect all data
      final fridgeItems = await _fridgeDataSource.getFridgeItems();
      final stockItems = await _stockDataSource.getStockItems();
      final shoppingListItems = await _shoppingListDataSource.getItems();
      final categories = await _categoryDataSource.getCategories();

      // Construct backup data
      final backupData = {
        'userId': userId,
        'fridgeItems': fridgeItems.map((item) => item.toJson()).toList(),
        'stockItems': stockItems.map((item) => item.toJson()).toList(),
        'shoppingListItems': shoppingListItems.map((item) => item.toJson()).toList(),
        'categories': categories.map((item) => item.toJson()).toList(),
        'backupDate': FieldValue.serverTimestamp(),
        'version': '1.0.0',
      };

      // Save backup to Firestore (user-specific subcollection)
      final backupId = DateTime.now().millisecondsSinceEpoch.toString();
      await _getUserBackupCollection(userId)
          .doc(backupId)
          .set(backupData);

      // Save backup metadata to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_backup_date', DateTime.now().toIso8601String());
    } catch (e) {
      throw Exception('Backup failed: $e');
    }
  }

  /// Restores all data from Firestore
  ///
  /// Retrieves the most recent backup from Firestore and restores all data:
  /// - Fridge items (existing items are deleted first)
  /// - Stock items (existing items are deleted first)
  /// - Shopping list items (replaces existing list)
  /// - Custom categories (replaces existing categories)
  ///
  /// Restoration metadata is saved to SharedPreferences.
  ///
  /// Throws: Exception if the user is not authenticated, no backup exists, or restoration fails
  Future<void> restoreAllData() async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      throw Exception('User is not logged in.');
    }

    try {
      // Get the most recent backup from Firestore
      final backupSnapshot = await _getUserBackupCollection(userId)
          .orderBy('backupDate', descending: true)
          .limit(1)
          .get();

      if (backupSnapshot.docs.isEmpty) {
        throw Exception('No backup data found');
      }

      final backupDoc = backupSnapshot.docs.first;

      if (!backupDoc.exists) {
        throw Exception('No backup data found');
      }

      final backupData = backupDoc.data() as Map<String, dynamic>;

      // Restore fridge items
      if (backupData['fridgeItems'] != null) {
        final fridgeItemsJson = backupData['fridgeItems'] as List<dynamic>;
        final fridgeItems = fridgeItemsJson
            .map((json) => FridgeItemModel.fromJson(json as Map<String, dynamic>))
            .toList();

        // Delete existing data before restoring
        final existingItems = await _fridgeDataSource.getFridgeItems();
        for (final item in existingItems) {
          await _fridgeDataSource.deleteFridgeItem(item.id);
        }

        for (final item in fridgeItems) {
          await _fridgeDataSource.addFridgeItem(item);
        }
      }

      // Restore stock items
      if (backupData['stockItems'] != null) {
        final stockItemsJson = backupData['stockItems'] as List<dynamic>;
        final stockItems = stockItemsJson
            .map((json) => StockItemModel.fromJson(json as Map<String, dynamic>))
            .toList();

        // Delete existing data before restoring
        final existingItems = await _stockDataSource.getStockItems();
        for (final item in existingItems) {
          await _stockDataSource.deleteStockItem(item.id);
        }

        for (final item in stockItems) {
          await _stockDataSource.addStockItem(item);
        }
      }

      // Restore shopping list items
      if (backupData['shoppingListItems'] != null) {
        final shoppingListItemsJson = backupData['shoppingListItems'] as List<dynamic>;
        final shoppingListItems = shoppingListItemsJson
            .map((json) => ShoppingListItemModel.fromJson(json as Map<String, dynamic>))
            .toList();

        await _shoppingListDataSource.saveItems(shoppingListItems);
      }

      // Restore categories
      if (backupData['categories'] != null) {
        final categoriesJson = backupData['categories'] as List<dynamic>;
        final categories = categoriesJson
            .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
            .toList();

        await _categoryDataSource.saveCategories(categories);
      }

      // Save restoration metadata
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_restore_date', DateTime.now().toIso8601String());
    } catch (e) {
      throw Exception('Restoration failed: $e');
    }
  }

  /// Gets the last backup date
  ///
  /// Retrieves the timestamp of the most recent backup from SharedPreferences.
  ///
  /// Returns: The last backup date, or null if no backup has been made
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

  /// Checks if backup data exists
  ///
  /// Queries Firestore to determine if at least one backup exists
  /// for the current user.
  ///
  /// Returns: `true` if backup data exists, `false` otherwise
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

