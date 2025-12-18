import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/app_keys.dart';
import '../models/alert_model.dart';
import 'alert_local_datasource.dart';

class AlertFirestoreDataSource implements AlertDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = AppKeys.alertsCollection;

  /// 현재 사용자 ID 가져오기
  String? _getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  /// 사용자별 컬렉션 경로 가져오기
  CollectionReference _getUserCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection(_collection);
  }

  @override
  Future<List<AlertModel>> getAlerts() async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      throw Exception('사용자가 로그인하지 않았습니다.');
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

  @override
  Future<void> markAsRead(String alertId) async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      throw Exception('사용자가 로그인하지 않았습니다.');
    }

    try {
      await _getUserCollection(userId)
          .doc(alertId)
          .update({'isRead': true});
    } catch (e) {
      throw Exception('Failed to mark alert as read: $e');
    }
  }

  @override
  Future<void> deleteAlert(String alertId) async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      throw Exception('사용자가 로그인하지 않았습니다.');
    }

    try {
      await _getUserCollection(userId).doc(alertId).delete();
    } catch (e) {
      throw Exception('Failed to delete alert: $e');
    }
  }

  Future<void> addAlert(AlertModel alert) async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      throw Exception('사용자가 로그인하지 않았습니다.');
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

