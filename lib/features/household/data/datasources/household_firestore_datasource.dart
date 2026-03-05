import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/household.dart';
import '../../domain/entities/household_member.dart';
import '../../domain/entities/household_role.dart';
import '../../domain/entities/invite_code.dart';
import '../models/household_model.dart';
import '../models/household_member_model.dart';
import '../models/invite_code_model.dart';

class HouseholdFirestoreDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final Uuid _uuid = const Uuid();

  static const String _householdsCollection = 'households';
  static const String _usersCollection = 'users';
  static const String _inviteCodesSubcollection = 'inviteCodes';
  static const String _fridgeItemsSubcollection = 'fridge_items';
  static const String _stockItemsSubcollection = 'stock_items';
  static const String _alertsCollection = 'alerts';

  HouseholdFirestoreDataSource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String? _getCurrentUserId() => _auth.currentUser?.uid;

  CollectionReference get _householdsRef =>
      _firestore.collection(_householdsCollection);

  CollectionReference get _usersRef => _firestore.collection(_usersCollection);

  // Household CRUD
  Future<Household?> getHousehold(String householdId) async {
    final doc = await _householdsRef.doc(householdId).get();
    if (!doc.exists) return null;
    return HouseholdModel.fromFirestore(doc);
  }

  Stream<Household?> watchHousehold(String householdId) {
    return _householdsRef.doc(householdId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return HouseholdModel.fromFirestore(doc);
    });
  }

  Future<Household> createHousehold(
    String name,
    String ownerId,
    HouseholdMember ownerMember,
  ) async {
    final docRef = _householdsRef.doc();
    final now = DateTime.now();

    final household = HouseholdModel(
      id: docRef.id,
      name: name,
      createdAt: now,
      ownerId: ownerId,
      members: {ownerId: ownerMember},
    );

    await docRef.set(household.toMap());
    return household;
  }

  Future<void> updateHousehold(Household household) async {
    final model = HouseholdModel.fromEntity(household);
    await _householdsRef.doc(household.id).update(model.toMap());
  }

  Future<void> deleteHousehold(String householdId) async {
    // Delete subcollections first
    await _deleteSubcollection(householdId, _fridgeItemsSubcollection);
    await _deleteSubcollection(householdId, _stockItemsSubcollection);
    await _deleteSubcollection(householdId, _inviteCodesSubcollection);

    // Delete the household document
    await _householdsRef.doc(householdId).delete();
  }

  Future<void> _deleteSubcollection(
      String householdId, String subcollection) async {
    final batch = _firestore.batch();
    final snapshots = await _householdsRef
        .doc(householdId)
        .collection(subcollection)
        .get();

    for (final doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // User's household
  Future<String?> getUserHouseholdId(String userId) async {
    final doc = await _usersRef.doc(userId).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>?;
    return data?['householdId'] as String?;
  }

  Stream<String?> watchUserHouseholdId(String userId) {
    return _usersRef.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = doc.data() as Map<String, dynamic>?;
      return data?['householdId'] as String?;
    });
  }

  Future<void> setUserHouseholdId(String userId, String? householdId) async {
    await _usersRef.doc(userId).set(
      {'householdId': householdId},
      SetOptions(merge: true),
    );
  }

  // Member management
  Future<void> addMember(String householdId, HouseholdMember member) async {
    final memberModel = HouseholdMemberModel.fromEntity(member);
    await _householdsRef.doc(householdId).update({
      'members.${member.id}': memberModel.toMap(),
    });
  }

  Future<void> updateMemberRole(
    String householdId,
    String memberId,
    HouseholdRole newRole,
  ) async {
    await _householdsRef.doc(householdId).update({
      'members.$memberId.role': newRole.name,
    });
  }

  Future<void> removeMember(String householdId, String memberId) async {
    await _householdsRef.doc(householdId).update({
      'members.$memberId': FieldValue.delete(),
    });
  }

  // Invite codes
  Future<InviteCode> generateInviteCode(
    String householdId,
    String createdBy,
  ) async {
    final code = _generateRandomCode();
    final now = DateTime.now();
    final expiresAt = now.add(const Duration(hours: 24));

    final inviteCodeRef =
        _householdsRef.doc(householdId).collection(_inviteCodesSubcollection).doc();

    final inviteCode = InviteCodeModel(
      id: inviteCodeRef.id,
      code: code,
      householdId: householdId,
      createdAt: now,
      expiresAt: expiresAt,
      createdBy: createdBy,
      used: false,
    );

    await inviteCodeRef.set(inviteCode.toMap());
    return inviteCode;
  }

  String _generateRandomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  Future<InviteCode?> getInviteCodeByCode(String code) async {
    // Search all households for the invite code
    final householdsSnapshot = await _householdsRef.get();

    for (final householdDoc in householdsSnapshot.docs) {
      final codesSnapshot = await householdDoc.reference
          .collection(_inviteCodesSubcollection)
          .where('code', isEqualTo: code)
          .where('used', isEqualTo: false)
          .limit(1)
          .get();

      if (codesSnapshot.docs.isNotEmpty) {
        final codeDoc = codesSnapshot.docs.first;
        final inviteCode =
            InviteCodeModel.fromFirestore(codeDoc, householdDoc.id);

        if (inviteCode.isValid) {
          return inviteCode;
        }
      }
    }
    return null;
  }

  Future<void> markInviteCodeUsed(String householdId, String codeId) async {
    await _householdsRef
        .doc(householdId)
        .collection(_inviteCodesSubcollection)
        .doc(codeId)
        .update({'used': true});
  }

  Future<List<InviteCode>> getActiveInviteCodes(String householdId) async {
    final now = DateTime.now();
    final snapshot = await _householdsRef
        .doc(householdId)
        .collection(_inviteCodesSubcollection)
        .where('used', isEqualTo: false)
        .where('expiresAt', isGreaterThan: Timestamp.fromDate(now))
        .get();

    return snapshot.docs
        .map((doc) => InviteCodeModel.fromFirestore(doc, householdId))
        .toList();
  }

  // Migration
  Future<void> migrateUserDataToHousehold({
    required String userId,
    required String householdId,
  }) async {
    final batch = _firestore.batch();

    // Migrate fridge_items
    final fridgeItems = await _usersRef
        .doc(userId)
        .collection(_fridgeItemsSubcollection)
        .get();

    for (final doc in fridgeItems.docs) {
      final newRef = _householdsRef
          .doc(householdId)
          .collection(_fridgeItemsSubcollection)
          .doc(doc.id);

      final data = Map<String, dynamic>.from(doc.data());
      data['addedBy'] = userId;
      data['lastModifiedBy'] = userId;

      batch.set(newRef, data);
    }

    // Migrate stock_items
    final stockItems = await _usersRef
        .doc(userId)
        .collection(_stockItemsSubcollection)
        .get();

    for (final doc in stockItems.docs) {
      final newRef = _householdsRef
          .doc(householdId)
          .collection(_stockItemsSubcollection)
          .doc(doc.id);

      final data = Map<String, dynamic>.from(doc.data());
      data['addedBy'] = userId;
      data['lastModifiedBy'] = userId;

      batch.set(newRef, data);
    }

    await batch.commit();
  }

  // Member join notification to Owner
  Future<void> notifyOwnerOfNewMember({
    required String householdId,
    required String newMemberName,
  }) async {
    // Get household to find owner
    final household = await getHousehold(householdId);
    if (household == null) return;

    final ownerId = household.ownerId;

    // Create alert for owner
    final alertId = _uuid.v4();
    final now = DateTime.now();

    await _usersRef
        .doc(ownerId)
        .collection(_alertsCollection)
        .doc(alertId)
        .set({
      'id': alertId,
      'type': 'member',
      'title': '新しいメンバーが参加しました',
      'message': '$newMemberNameさんが冷蔵庫の共有メンバーに参加しました。メンバー管理で権限を変更できます。',
      'createdAt': now.toIso8601String(),
      'isRead': false,
    });
  }

  // Member leave notification to Owner
  Future<void> notifyOwnerOfMemberLeft({
    required String householdId,
    required String memberName,
  }) async {
    final household = await getHousehold(householdId);
    if (household == null) return;

    final ownerId = household.ownerId;
    final alertId = _uuid.v4();
    final now = DateTime.now();

    await _usersRef
        .doc(ownerId)
        .collection(_alertsCollection)
        .doc(alertId)
        .set({
      'id': alertId,
      'type': 'member',
      'title': 'メンバーが退出しました',
      'message': '$memberNameさんが冷蔵庫の共有から退出しました。',
      'createdAt': now.toIso8601String(),
      'isRead': false,
    });
  }
}
