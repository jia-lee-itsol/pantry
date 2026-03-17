import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/app_keys.dart';
import '../models/purchase_model.dart';

class PurchaseFirestoreDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = AppKeys.purchasesCollection;

  Future<String?> _getCurrentHouseholdId() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;

    final userDoc = await _firestore.collection('users').doc(userId).get();
    return userDoc.data()?['householdId'] as String?;
  }

  CollectionReference _getHouseholdCollection(String householdId) {
    return _firestore
        .collection('households')
        .doc(householdId)
        .collection(_collection);
  }

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

  Future<void> addPurchase(PurchaseModel purchase) async {
    final householdId = await _getCurrentHouseholdId();
    if (householdId == null) return;

    final data = purchase.toJson();
    data.remove('id');
    await _getHouseholdCollection(householdId).doc(purchase.id).set(data);
  }

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

  Future<void> deletePurchase(String id) async {
    final householdId = await _getCurrentHouseholdId();
    if (householdId == null) return;

    await _getHouseholdCollection(householdId).doc(id).delete();
  }
}
