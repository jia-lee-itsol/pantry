import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/app_keys.dart';
import '../models/purchase_model.dart';

/// Firestore data source for purchase records.
///
/// This class handles all Firestore operations for purchase data, storing
/// purchases in household-specific subcollections. Each household has its
/// own purchases collection for multi-user support.
class PurchaseFirestoreDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = AppKeys.purchasesCollection;

  /// Gets the current user's household ID from Firestore.
  ///
  /// Returns the household ID string if the user is authenticated and
  /// belongs to a household, null otherwise.
  Future<String?> _getCurrentHouseholdId() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;

    final userDoc = await _firestore.collection('users').doc(userId).get();
    return userDoc.data()?['householdId'] as String?;
  }

  /// Gets the Firestore collection reference for a household's purchases.
  ///
  /// Parameters:
  ///   [householdId] - The ID of the household
  ///
  /// Returns a [CollectionReference] to the household's purchases subcollection.
  CollectionReference _getHouseholdCollection(String householdId) {
    return _firestore
        .collection('households')
        .doc(householdId)
        .collection(_collection);
  }

  /// Retrieves all purchases for the current household.
  ///
  /// Fetches purchases ordered by purchase date (newest first).
  ///
  /// Returns a list of [PurchaseModel] objects, or an empty list if
  /// the user is not authenticated or doesn't belong to a household.
  Future<List<PurchaseModel>> getPurchases() async {
    final householdId = await _getCurrentHouseholdId();
    if (householdId == null) return [];

    final snapshot = await _getHouseholdCollection(householdId)
        .orderBy('purchaseDate', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => PurchaseModel.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }))
        .toList();
  }

  /// Retrieves purchases within a specific date range.
  ///
  /// Parameters:
  ///   [start] - Start date of the range
  ///   [end] - End date of the range
  ///
  /// Returns a list of [PurchaseModel] objects within the date range,
  /// or an empty list if the user doesn't belong to a household.
  Future<List<PurchaseModel>> getPurchasesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final householdId = await _getCurrentHouseholdId();
    if (householdId == null) return [];

    final snapshot = await _getHouseholdCollection(householdId)
        .where('purchaseDate', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('purchaseDate', isLessThanOrEqualTo: end.toIso8601String())
        .orderBy('purchaseDate', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => PurchaseModel.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }))
        .toList();
  }

  /// Adds a single purchase to Firestore.
  ///
  /// Parameters:
  ///   [purchase] - The purchase model to add
  ///
  /// Does nothing if the user doesn't belong to a household.
  Future<void> addPurchase(PurchaseModel purchase) async {
    final householdId = await _getCurrentHouseholdId();
    if (householdId == null) return;

    final data = purchase.toJson();
    data.remove('id');
    await _getHouseholdCollection(householdId).doc(purchase.id).set(data);
  }

  /// Adds multiple purchases to Firestore in a batch operation.
  ///
  /// Parameters:
  ///   [purchases] - The list of purchase models to add
  ///
  /// Uses Firestore batch writes for efficient bulk insertion.
  /// Does nothing if the user doesn't belong to a household.
  Future<void> addPurchases(List<PurchaseModel> purchases) async {
    final householdId = await _getCurrentHouseholdId();
    if (householdId == null) return;

    final batch = _firestore.batch();
    final collection = _getHouseholdCollection(householdId);

    for (final purchase in purchases) {
      final data = purchase.toJson();
      data.remove('id');
      batch.set(collection.doc(purchase.id), data);
    }

    await batch.commit();
  }

  /// Deletes a purchase from Firestore.
  ///
  /// Parameters:
  ///   [id] - The unique identifier of the purchase to delete
  ///
  /// Does nothing if the user doesn't belong to a household.
  Future<void> deletePurchase(String id) async {
    final householdId = await _getCurrentHouseholdId();
    if (householdId == null) return;

    await _getHouseholdCollection(householdId).doc(id).delete();
  }
}
