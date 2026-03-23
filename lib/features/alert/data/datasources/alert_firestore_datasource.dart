import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/app_keys.dart';
import '../models/alert_model.dart';
import 'alert_local_datasource.dart';

/// Firestore implementation of the alert data source.
///
/// This class handles all Firestore operations for alerts, storing them
/// in user-specific subcollections. Each user has their own alerts collection
/// under their user document.
class AlertFirestoreDataSource implements AlertDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = AppKeys.alertsCollection;

  /// Gets the current authenticated user's ID.
  ///
  /// Returns the user ID string if authenticated, null otherwise.
  String? _getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  /// Gets the Firestore collection reference for a specific user's alerts.
  ///
  /// Parameters:
  ///   [userId] - The ID of the user whose alert collection to retrieve
  ///
  /// Returns a [CollectionReference] pointing to the user's alerts subcollection.
  CollectionReference _getUserCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection(_collection);
  }

  /// Retrieves all alerts for the current user from Firestore.
  ///
  /// Fetches alerts ordered by creation date (newest first).
  ///
  /// Returns a list of [AlertModel] objects.
  /// Throws an exception if the user is not logged in or if the operation fails.
  @override
  Future<List<AlertModel>> getAlerts() async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      throw Exception('User is not logged in.');
    }

    try {
      final snapshot = await _getUserCollection(userId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return AlertModel.fromJson({
              'id': doc.id,
              ...data,
            });
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to get alerts: $e');
    }
  }

  /// Marks an alert as read in Firestore.
  ///
  /// Updates the 'isRead' field to true for the specified alert.
  ///
  /// Parameters:
  ///   [alertId] - The unique identifier of the alert to mark as read
  ///
  /// Throws an exception if the user is not logged in or if the operation fails.
  @override
  Future<void> markAsRead(String alertId) async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      throw Exception('User is not logged in.');
    }

    try {
      await _getUserCollection(userId)
          .doc(alertId)
          .update({'isRead': true});
    } catch (e) {
      throw Exception('Failed to mark alert as read: $e');
    }
  }

  /// Deletes an alert from Firestore.
  ///
  /// Permanently removes the specified alert document from the database.
  ///
  /// Parameters:
  ///   [alertId] - The unique identifier of the alert to delete
  ///
  /// Throws an exception if the user is not logged in or if the operation fails.
  @override
  Future<void> deleteAlert(String alertId) async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      throw Exception('User is not logged in.');
    }

    try {
      await _getUserCollection(userId).doc(alertId).delete();
    } catch (e) {
      throw Exception('Failed to delete alert: $e');
    }
  }

  /// Adds a new alert to Firestore.
  ///
  /// Creates a new alert document in the user's alerts collection.
  ///
  /// Parameters:
  ///   [alert] - The alert model to be added
  ///
  /// Throws an exception if the user is not logged in or if the operation fails.
  Future<void> addAlert(AlertModel alert) async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      throw Exception('User is not logged in.');
    }

    try {
      await _getUserCollection(userId)
          .doc(alert.id)
          .set(alert.toJson());
    } catch (e) {
      throw Exception('Failed to add alert: $e');
    }
  }
}

