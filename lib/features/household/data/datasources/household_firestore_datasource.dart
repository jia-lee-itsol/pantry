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

/// Firestore data source for household-related operations.
///
/// This class handles all Firestore interactions for:
/// - Household CRUD operations
/// - Member management (add, remove, update roles)
/// - Invite code generation and validation
/// - Username registration and lookup
/// - Household join requests
/// - User notifications/alerts
///
/// ## Firestore Structure:
/// ```
/// households/{householdId}
///   - name, ownerId, createdAt
///   - members: Map<userId, HouseholdMember>
///   └── inviteCodes/{codeId}
///   └── fridge_items/{itemId}
///   └── stock_items/{itemId}
///
/// users/{userId}
///   - householdId, username, displayName, photoUrl
///   └── alerts/{alertId}
///
/// usernames/{username} -> userId (for unique username lookup)
/// invite_codes/{code} -> householdId, codeId (for O(1) code lookup)
/// household_requests/{requestId}
/// ```
class HouseholdFirestoreDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final Uuid _uuid = const Uuid();

  // ============================================
  // Collection and Subcollection Names
  // ============================================

  /// Top-level collection for household documents
  static const String _householdsCollection = 'households';

  /// Top-level collection for user documents
  static const String _usersCollection = 'users';

  /// Top-level collection for username -> userId mapping (ensures uniqueness)
  static const String _usernamesCollection = 'usernames';

  /// Top-level collection for household join requests
  static const String _householdRequestsCollection = 'household_requests';

  /// Top-level lookup table for invite codes (enables O(1) code search)
  static const String _inviteCodesCollection = 'invite_codes';

  /// Subcollection under households for invite codes
  static const String _inviteCodesSubcollection = 'inviteCodes';

  /// Subcollection under households for fridge items
  static const String _fridgeItemsSubcollection = 'fridge_items';

  /// Subcollection under households for stock items
  static const String _stockItemsSubcollection = 'stock_items';

  /// Subcollection under users for alerts/notifications
  static const String _alertsCollection = 'alerts';

  // ============================================
  // Constructor and Collection References
  // ============================================

  /// Creates a new [HouseholdFirestoreDataSource].
  ///
  /// Optionally accepts custom [firestore] and [auth] instances for testing.
  HouseholdFirestoreDataSource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  CollectionReference get _householdsRef =>
      _firestore.collection(_householdsCollection);

  CollectionReference get _usersRef => _firestore.collection(_usersCollection);

  CollectionReference get _usernamesRef =>
      _firestore.collection(_usernamesCollection);

  CollectionReference get _householdRequestsRef =>
      _firestore.collection(_householdRequestsCollection);

  CollectionReference get _inviteCodesRef =>
      _firestore.collection(_inviteCodesCollection);

  // ============================================
  // Household CRUD Operations
  // ============================================

  /// Fetches a household by its ID.
  ///
  /// Returns `null` if the household does not exist.
  Future<Household?> getHousehold(String householdId) async {
    final doc = await _householdsRef.doc(householdId).get();
    if (!doc.exists) return null;
    return HouseholdModel.fromFirestore(doc);
  }

  /// Returns a real-time stream of household data.
  ///
  /// Emits `null` if the household is deleted.
  Stream<Household?> watchHousehold(String householdId) {
    return _householdsRef.doc(householdId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return HouseholdModel.fromFirestore(doc);
    });
  }

  /// Creates a new household with the given [name] and [ownerId].
  ///
  /// The [ownerMember] is added as the first member with owner privileges.
  /// A permanent invite code is automatically generated.
  /// Returns the created [Household] with a generated Firestore document ID.
  Future<Household> createHousehold(
    String name,
    String ownerId,
    HouseholdMember ownerMember,
  ) async {
    final docRef = _householdsRef.doc();
    final now = DateTime.now();
    final inviteCode = _generateRandomCode();

    final household = HouseholdModel(
      id: docRef.id,
      name: name,
      createdAt: now,
      ownerId: ownerId,
      members: {ownerId: ownerMember},
      inviteCode: inviteCode,
    );

    // Use batch to create household and register invite code in lookup table
    final batch = _firestore.batch();

    batch.set(docRef, household.toMap());

    // Register permanent code in lookup table
    batch.set(_inviteCodesRef.doc(inviteCode), {
      'householdId': docRef.id,
      'isPermanent': true,
      'used': false,
    });

    await batch.commit();
    return household;
  }

  /// Updates an existing household document.
  ///
  /// Replaces all fields with values from the given [household] entity.
  Future<void> updateHousehold(Household household) async {
    final model = HouseholdModel.fromEntity(household);
    await _householdsRef.doc(household.id).update(model.toMap());
  }

  /// Deletes a household and all its associated data.
  ///
  /// This includes:
  /// - All fridge items in the household
  /// - All stock items in the household
  /// - All invite codes (both subcollection and lookup table)
  /// - The household document itself
  ///
  /// **Warning**: This operation is irreversible.
  Future<void> deleteHousehold(String householdId) async {
    // Delete subcollections first
    await _deleteSubcollection(householdId, _fridgeItemsSubcollection);
    await _deleteSubcollection(householdId, _stockItemsSubcollection);

    // Delete invite codes from lookup table before deleting subcollection
    await _deleteInviteCodesFromLookup(householdId);
    await _deleteSubcollection(householdId, _inviteCodesSubcollection);

    // Delete the household document
    await _householdsRef.doc(householdId).delete();
  }

  /// Removes all invite codes from the top-level lookup table.
  ///
  /// Called before deleting the household's invite codes subcollection
  /// to maintain consistency between the two storage locations.
  /// Processes deletions in batches of 500 to respect Firestore limits.
  Future<void> _deleteInviteCodesFromLookup(String householdId) async {
    const batchLimit = 500;
    final snapshots = await _householdsRef
        .doc(householdId)
        .collection(_inviteCodesSubcollection)
        .get();

    final docs = snapshots.docs;
    for (var i = 0; i < docs.length; i += batchLimit) {
      final batch = _firestore.batch();
      final end = (i + batchLimit < docs.length) ? i + batchLimit : docs.length;
      for (var j = i; j < end; j++) {
        final data = docs[j].data();
        final codeString = data['code'] as String?;
        if (codeString != null) {
          batch.delete(_inviteCodesRef.doc(codeString));
        }
      }
      await batch.commit();
    }
  }

  /// Deletes all documents in a subcollection.
  ///
  /// Processes deletions in batches of 500 to respect Firestore's
  /// batch operation limit.
  Future<void> _deleteSubcollection(
    String householdId,
    String subcollection,
  ) async {
    const batchLimit = 500;
    final snapshots = await _householdsRef
        .doc(householdId)
        .collection(subcollection)
        .get();

    final docs = snapshots.docs;
    for (var i = 0; i < docs.length; i += batchLimit) {
      final batch = _firestore.batch();
      final end = (i + batchLimit < docs.length) ? i + batchLimit : docs.length;
      for (var j = i; j < end; j++) {
        batch.delete(docs[j].reference);
      }
      await batch.commit();
    }
  }

  // ============================================
  // User-Household Association
  // ============================================

  /// Gets the household ID associated with a user.
  ///
  /// Returns `null` if the user has no household or doesn't exist.
  Future<String?> getUserHouseholdId(String userId) async {
    final doc = await _usersRef.doc(userId).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>?;
    return data?['householdId'] as String?;
  }

  /// Returns a real-time stream of the user's household ID.
  ///
  /// Useful for detecting when a user joins or leaves a household.
  Stream<String?> watchUserHouseholdId(String userId) {
    return _usersRef.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = doc.data() as Map<String, dynamic>?;
      return data?['householdId'] as String?;
    });
  }

  /// Sets or clears the user's household association.
  ///
  /// Pass `null` to remove the user from their current household.
  /// Uses merge to preserve other user document fields.
  Future<void> setUserHouseholdId(String userId, String? householdId) async {
    await _usersRef.doc(userId).set({
      'householdId': householdId,
    }, SetOptions(merge: true));
  }

  // ============================================
  // Member Management
  // ============================================

  /// Adds a new member to a household.
  ///
  /// The member data is stored in the household's `members` map
  /// using the member's ID as the key.
  Future<void> addMember(String householdId, HouseholdMember member) async {
    final memberModel = HouseholdMemberModel.fromEntity(member);
    await _householdsRef.doc(householdId).update({
      'members.${member.id}': memberModel.toMap(),
    });
  }

  /// Updates a member's role within a household.
  ///
  /// Available roles are defined in [HouseholdRole]:
  /// - `owner`: Full control, can manage members and delete household
  /// - `editor`: Can add/edit/delete items
  /// - `viewer`: Read-only access
  Future<void> updateMemberRole(
    String householdId,
    String memberId,
    HouseholdRole newRole,
  ) async {
    await _householdsRef.doc(householdId).update({
      'members.$memberId.role': newRole.name,
    });
  }

  /// Removes a member from a household.
  ///
  /// Uses [FieldValue.delete] to remove the member entry from the map.
  /// Does not update the user's `householdId` - that must be done separately.
  Future<void> removeMember(String householdId, String memberId) async {
    await _householdsRef.doc(householdId).update({
      'members.$memberId': FieldValue.delete(),
    });
  }

  // ============================================
  // Invite Code Management
  // ============================================

  /// Generates a new invite code for a household.
  ///
  /// Creates a 6-character alphanumeric code that expires in 24 hours.
  /// The code is stored in two locations for efficient access:
  /// 1. Household subcollection: `households/{id}/inviteCodes/{codeId}`
  /// 2. Top-level lookup table: `invite_codes/{code}` (for O(1) lookup)
  ///
  /// Returns the created [InviteCode] with all metadata.
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

    // Use batch to write to both subcollection and lookup table
    final batch = _firestore.batch();

    // Write to household's subcollection
    batch.set(inviteCodeRef, inviteCode.toMap());

    // Write to top-level lookup table (key: code)
    batch.set(_inviteCodesRef.doc(code), {
      'householdId': householdId,
      'codeId': inviteCodeRef.id,
      'expiresAt': Timestamp.fromDate(expiresAt),
      'used': false,
    });

    await batch.commit();
    return inviteCode;
  }

  /// Generates a random 6-character invite code.
  ///
  /// Uses uppercase letters (excluding I, O) and digits (excluding 0, 1)
  /// to avoid confusion between similar-looking characters.
  /// Uses [Random.secure] for cryptographically secure randomness.
  String _generateRandomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Looks up an invite code by its string value.
  ///
  /// Uses the top-level `invite_codes` collection for O(1) lookup
  /// instead of scanning all households.
  ///
  /// Supports both permanent codes (stored in household document)
  /// and temporary codes (stored in inviteCodes subcollection).
  ///
  /// Returns `null` if:
  /// - The code doesn't exist
  /// - The temporary code has already been used
  /// - The temporary code has expired
  Future<InviteCode?> getInviteCodeByCode(String code) async {
    // Direct lookup from top-level invite_codes collection
    final lookupDoc = await _inviteCodesRef.doc(code).get();
    if (!lookupDoc.exists) return null;

    final lookupData = lookupDoc.data() as Map<String, dynamic>?;
    if (lookupData == null) return null;

    final householdId = lookupData['householdId'] as String;
    final isPermanent = lookupData['isPermanent'] as bool? ?? false;

    // Handle permanent invite codes
    if (isPermanent) {
      final household = await getHousehold(householdId);
      if (household == null) return null;

      return InviteCodeModel.permanent(
        code: code,
        householdId: householdId,
        ownerId: household.ownerId,
        createdAt: household.createdAt,
      );
    }

    // Handle temporary invite codes
    // Check if already used
    if (lookupData['used'] == true) return null;

    final codeId = lookupData['codeId'] as String;

    // Fetch the full invite code document
    final codeDoc = await _householdsRef
        .doc(householdId)
        .collection(_inviteCodesSubcollection)
        .doc(codeId)
        .get();

    if (!codeDoc.exists) return null;

    final inviteCode = InviteCodeModel.fromFirestore(codeDoc, householdId);
    if (!inviteCode.isValid) return null;

    return inviteCode;
  }

  /// Marks an invite code as used.
  ///
  /// Updates both the subcollection document and the lookup table
  /// to maintain consistency. Uses a batch write for atomicity.
  Future<void> markInviteCodeUsed(String householdId, String codeId) async {
    // First get the invite code to find the code string
    final codeDoc = await _householdsRef
        .doc(householdId)
        .collection(_inviteCodesSubcollection)
        .doc(codeId)
        .get();

    if (!codeDoc.exists) return;

    final codeData = codeDoc.data();
    final codeString = codeData?['code'] as String?;

    final batch = _firestore.batch();

    // Update subcollection document
    batch.update(
      _householdsRef
          .doc(householdId)
          .collection(_inviteCodesSubcollection)
          .doc(codeId),
      {'used': true},
    );

    // Update lookup table if code string exists
    if (codeString != null) {
      batch.update(_inviteCodesRef.doc(codeString), {'used': true});
    }

    await batch.commit();
  }

  /// Gets all active (unused and not expired) invite codes for a household.
  ///
  /// Returns codes sorted by Firestore's default ordering.
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

  // ============================================
  // Data Migration
  // ============================================

  /// Migrates a user's personal data to a household.
  ///
  /// This is called when a user creates or joins a household for the first time.
  /// Copies all fridge items and stock items from the user's personal storage
  /// to the household's shared storage.
  ///
  /// Each migrated item is tagged with:
  /// - `addedBy`: The original owner's user ID
  /// - `lastModifiedBy`: The original owner's user ID
  ///
  /// Processes in batches of 500 to respect Firestore's batch operation limit.
  Future<void> migrateUserDataToHousehold({
    required String userId,
    required String householdId,
  }) async {
    const batchLimit = 500;

    // Migrate fridge_items
    final fridgeItems = await _usersRef
        .doc(userId)
        .collection(_fridgeItemsSubcollection)
        .get();

    // Migrate stock_items
    final stockItems = await _usersRef
        .doc(userId)
        .collection(_stockItemsSubcollection)
        .get();

    // Combine all documents to migrate
    final allDocs = <MapEntry<DocumentReference, Map<String, dynamic>>>[];

    for (final doc in fridgeItems.docs) {
      final newRef = _householdsRef
          .doc(householdId)
          .collection(_fridgeItemsSubcollection)
          .doc(doc.id);

      final data = Map<String, dynamic>.from(doc.data());
      data['addedBy'] = userId;
      data['lastModifiedBy'] = userId;

      allDocs.add(MapEntry(newRef, data));
    }

    for (final doc in stockItems.docs) {
      final newRef = _householdsRef
          .doc(householdId)
          .collection(_stockItemsSubcollection)
          .doc(doc.id);

      final data = Map<String, dynamic>.from(doc.data());
      data['addedBy'] = userId;
      data['lastModifiedBy'] = userId;

      allDocs.add(MapEntry(newRef, data));
    }

    // Process in batches of 500
    for (var i = 0; i < allDocs.length; i += batchLimit) {
      final batch = _firestore.batch();
      final end =
          (i + batchLimit < allDocs.length) ? i + batchLimit : allDocs.length;
      for (var j = i; j < end; j++) {
        batch.set(allDocs[j].key, allDocs[j].value);
      }
      await batch.commit();
    }
  }

  /// Generates a permanent invite code for existing households.
  ///
  /// This migration method is called for households that were created
  /// before the permanent invite code feature was added.
  /// If the household already has an invite code, this method does nothing.
  Future<void> migrateHouseholdInviteCode(String householdId) async {
    final household = await getHousehold(householdId);
    if (household == null) return;

    // Skip if household already has an invite code
    if (household.inviteCode.isNotEmpty) return;

    // Generate new permanent invite code
    final inviteCode = _generateRandomCode();

    // Use batch to update household and register code in lookup table
    final batch = _firestore.batch();

    // Update household with invite code
    batch.update(_householdsRef.doc(householdId), {
      'inviteCode': inviteCode,
    });

    // Register permanent code in lookup table
    batch.set(_inviteCodesRef.doc(inviteCode), {
      'householdId': householdId,
      'isPermanent': true,
      'used': false,
    });

    await batch.commit();
  }

  // ============================================
  // Member Notifications
  // ============================================

  /// Notifies the household owner when a new member joins.
  ///
  /// Creates an alert in the owner's alerts subcollection.
  /// The alert includes the new member's name and guidance
  /// about managing member permissions.
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

  /// Notifies the household owner when a member leaves.
  ///
  /// Creates an alert in the owner's alerts subcollection.
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
          'title': '共同管理への招待が届きました',
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
          'title': '招待が承諾されました',
          'message': '$receiverNameさんが招待を承諾しました。',
          'createdAt': now.toIso8601String(),
          'isRead': false,
        });
  }
}
