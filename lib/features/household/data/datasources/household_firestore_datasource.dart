import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../../../auth/domain/entities/user_profile.dart';
import '../../../auth/data/models/user_profile_model.dart';
import '../../domain/entities/household.dart';
import '../../domain/entities/household_member.dart';
import '../../domain/entities/household_role.dart';
import '../../domain/entities/household_request.dart';
import '../../domain/entities/invite_code.dart';
import '../models/household_model.dart';
import '../models/household_member_model.dart';
import '../models/household_request_model.dart';
import '../models/invite_code_model.dart';

class HouseholdFirestoreDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final Uuid _uuid = const Uuid();

  static const String _householdsCollection = 'households';
  static const String _usersCollection = 'users';
  static const String _usernamesCollection = 'usernames';
  static const String _householdRequestsCollection = 'household_requests';
  static const String _inviteCodesSubcollection = 'inviteCodes';
  static const String _fridgeItemsSubcollection = 'fridge_items';
  static const String _stockItemsSubcollection = 'stock_items';
  static const String _alertsCollection = 'alerts';

  HouseholdFirestoreDataSource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  String? _getCurrentUserId() => _auth.currentUser?.uid;

  CollectionReference get _householdsRef =>
      _firestore.collection(_householdsCollection);

  CollectionReference get _usersRef => _firestore.collection(_usersCollection);

  CollectionReference get _usernamesRef =>
      _firestore.collection(_usernamesCollection);

  CollectionReference get _householdRequestsRef =>
      _firestore.collection(_householdRequestsCollection);

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
    String householdId,
    String subcollection,
  ) async {
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
    await _usersRef.doc(userId).set({
      'householdId': householdId,
    }, SetOptions(merge: true));
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

    final inviteCodeRef = _householdsRef
        .doc(householdId)
        .collection(_inviteCodesSubcollection)
        .doc();

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
        final inviteCode = InviteCodeModel.fromFirestore(
          codeDoc,
          householdDoc.id,
        );

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

  // ============================================
  // Username Management
  // ============================================

  /// Check if username is available
  Future<bool> isUsernameAvailable(String username) async {
    final doc = await _usernamesRef.doc(username.toLowerCase()).get();
    return !doc.exists;
  }

  /// Register a username for a user (can only be done once)
  Future<void> registerUsername(String userId, String username) async {
    final lowerUsername = username.toLowerCase();
    final now = DateTime.now();

    // Check if user already has a username
    final userDoc = await _usersRef.doc(userId).get();
    final userData = userDoc.data() as Map<String, dynamic>?;
    if (userData?['username'] != null) {
      throw Exception('Username already registered');
    }

    // Check availability again
    final available = await isUsernameAvailable(lowerUsername);
    if (!available) {
      throw Exception('Username is already taken');
    }

    // Use batch write for atomicity
    final batch = _firestore.batch();

    // Create username document
    batch.set(_usernamesRef.doc(lowerUsername), {
      'userId': userId,
      'createdAt': Timestamp.fromDate(now),
    });

    // Update user document
    batch.update(_usersRef.doc(userId), {
      'username': lowerUsername,
      'usernameSetAt': Timestamp.fromDate(now),
    });

    await batch.commit();
  }

  /// Get username by user ID
  Future<String?> getUsernameByUserId(String userId) async {
    final doc = await _usersRef.doc(userId).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>?;
    return data?['username'] as String?;
  }

  /// Get user ID by username
  Future<String?> getUserIdByUsername(String username) async {
    final doc = await _usernamesRef.doc(username.toLowerCase()).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>?;
    return data?['userId'] as String?;
  }

  // ============================================
  // User Search
  // ============================================

  /// Find user by username
  Future<UserProfile?> findUserByUsername(String username) async {
    final userId = await getUserIdByUsername(username);
    if (userId == null) return null;

    final userDoc = await _usersRef.doc(userId).get();
    if (!userDoc.exists) return null;

    final userData = userDoc.data() as Map<String, dynamic>?;
    if (userData == null) return null;

    return UserProfileModel(
      id: userId,
      username: userData['username'] as String? ?? username.toLowerCase(),
      displayName: userData['displayName'] as String?,
      photoUrl: userData['photoUrl'] as String?,
    );
  }

  // ============================================
  // Household Request Management
  // ============================================

  /// Create a household request
  Future<HouseholdRequest> createHouseholdRequest({
    required String senderId,
    required String senderUsername,
    required String? senderDisplayName,
    required String? senderPhotoUrl,
    required String receiverId,
    required String receiverUsername,
    required String householdId,
    required String householdName,
  }) async {
    final docRef = _householdRequestsRef.doc();
    final now = DateTime.now();

    final request = HouseholdRequestModel(
      id: docRef.id,
      senderId: senderId,
      senderUsername: senderUsername,
      senderDisplayName: senderDisplayName,
      senderPhotoUrl: senderPhotoUrl,
      receiverId: receiverId,
      receiverUsername: receiverUsername,
      householdId: householdId,
      householdName: householdName,
      status: HouseholdRequestStatus.pending,
      createdAt: now,
    );

    await docRef.set(request.toMap());

    // Send notification to receiver
    await notifyUserOfHouseholdRequest(
      receiverId: receiverId,
      senderName: senderDisplayName ?? senderUsername,
      householdName: householdName,
      requestId: docRef.id,
    );

    return request;
  }

  /// Get received requests for a user
  Future<List<HouseholdRequest>> getReceivedRequests(String userId) async {
    final snapshot = await _householdRequestsRef
        .where('receiverId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => HouseholdRequestModel.fromFirestore(doc))
        .toList();
  }

  /// Watch received requests (real-time)
  Stream<List<HouseholdRequest>> watchReceivedRequests(String userId) {
    return _householdRequestsRef
        .where('receiverId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => HouseholdRequestModel.fromFirestore(doc))
            .toList());
  }

  /// Get sent requests by a user
  Future<List<HouseholdRequest>> getSentRequests(String userId) async {
    final snapshot = await _householdRequestsRef
        .where('senderId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => HouseholdRequestModel.fromFirestore(doc))
        .toList();
  }

  /// Watch sent requests (real-time)
  Stream<List<HouseholdRequest>> watchSentRequests(String userId) {
    return _householdRequestsRef
        .where('senderId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => HouseholdRequestModel.fromFirestore(doc))
            .toList());
  }

  /// Get a single request by ID
  Future<HouseholdRequest?> getHouseholdRequest(String requestId) async {
    final doc = await _householdRequestsRef.doc(requestId).get();
    if (!doc.exists) return null;
    return HouseholdRequestModel.fromFirestore(doc);
  }

  /// Accept a household request
  Future<void> acceptHouseholdRequest(String requestId) async {
    final request = await getHouseholdRequest(requestId);
    if (request == null) throw Exception('Request not found');
    if (!request.isPending) throw Exception('Request is not pending');

    final now = DateTime.now();
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not logged in');

    // Verify the current user is the receiver
    if (request.receiverId != currentUser.uid) {
      throw Exception('Not authorized to accept this request');
    }

    // Create household member
    final member = HouseholdMember(
      id: currentUser.uid,
      role: HouseholdRole.viewer,
      joinedAt: now,
      displayName: currentUser.displayName,
      photoUrl: currentUser.photoURL,
      email: currentUser.email,
    );

    // Use batch write
    final batch = _firestore.batch();

    // Update request status
    batch.update(_householdRequestsRef.doc(requestId), {
      'status': 'accepted',
      'respondedAt': Timestamp.fromDate(now),
    });

    // Add member to household
    final memberModel = HouseholdMemberModel.fromEntity(member);
    batch.update(_householdsRef.doc(request.householdId), {
      'members.${currentUser.uid}': memberModel.toMap(),
    });

    // Update user's householdId
    batch.update(_usersRef.doc(currentUser.uid), {
      'householdId': request.householdId,
    });

    await batch.commit();

    // Notify sender that request was accepted
    await notifyUserOfRequestAccepted(
      senderId: request.senderId,
      receiverName:
          currentUser.displayName ?? request.receiverUsername,
    );

    // Notify owner of new member
    await notifyOwnerOfNewMember(
      householdId: request.householdId,
      newMemberName: currentUser.displayName ?? request.receiverUsername,
    );
  }

  /// Reject a household request
  Future<void> rejectHouseholdRequest(String requestId) async {
    final request = await getHouseholdRequest(requestId);
    if (request == null) throw Exception('Request not found');
    if (!request.isPending) throw Exception('Request is not pending');

    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not logged in');

    // Verify the current user is the receiver
    if (request.receiverId != currentUser.uid) {
      throw Exception('Not authorized to reject this request');
    }

    final now = DateTime.now();

    await _householdRequestsRef.doc(requestId).update({
      'status': 'rejected',
      'respondedAt': Timestamp.fromDate(now),
    });
  }

  /// Cancel a sent request
  Future<void> cancelHouseholdRequest(String requestId) async {
    final request = await getHouseholdRequest(requestId);
    if (request == null) throw Exception('Request not found');
    if (!request.isPending) throw Exception('Request is not pending');

    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not logged in');

    // Verify the current user is the sender
    if (request.senderId != currentUser.uid) {
      throw Exception('Not authorized to cancel this request');
    }

    await _householdRequestsRef.doc(requestId).delete();
  }

  /// Check if a request already exists between sender and receiver
  Future<bool> hasExistingRequest({
    required String senderId,
    required String receiverId,
  }) async {
    final snapshot = await _householdRequestsRef
        .where('senderId', isEqualTo: senderId)
        .where('receiverId', isEqualTo: receiverId)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  // ============================================
  // Request Notifications
  // ============================================

  /// Notify user of household request
  Future<void> notifyUserOfHouseholdRequest({
    required String receiverId,
    required String senderName,
    required String householdName,
    required String requestId,
  }) async {
    final alertId = _uuid.v4();
    final now = DateTime.now();

    await _usersRef
        .doc(receiverId)
        .collection(_alertsCollection)
        .doc(alertId)
        .set({
          'id': alertId,
          'type': 'householdRequest',
          'title': '공동관리 초대가 도착했습니다',
          'message': '$senderNameさんが「$householdName」への参加を招待しています。',
          'createdAt': now.toIso8601String(),
          'isRead': false,
          'metadata': {
            'requestId': requestId,
            'action': 'view_request',
          },
        });
  }

  /// Notify sender that request was accepted
  Future<void> notifyUserOfRequestAccepted({
    required String senderId,
    required String receiverName,
  }) async {
    final alertId = _uuid.v4();
    final now = DateTime.now();

    await _usersRef
        .doc(senderId)
        .collection(_alertsCollection)
        .doc(alertId)
        .set({
          'id': alertId,
          'type': 'member',
          'title': '초대가 수락되었습니다',
          'message': '$receiverNameさんが招待を承諾しました。',
          'createdAt': now.toIso8601String(),
          'isRead': false,
        });
  }
}
