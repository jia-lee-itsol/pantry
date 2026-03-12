import '../../../auth/domain/entities/user_profile.dart';
import '../entities/household.dart';
import '../entities/household_member.dart';
import '../entities/household_request.dart';
import '../entities/household_role.dart';
import '../entities/invite_code.dart';

abstract class HouseholdRepository {
  // Household CRUD
  Future<Household?> getHousehold(String householdId);
  Stream<Household?> watchHousehold(String householdId);
  Future<Household> createHousehold(String name, String ownerId, HouseholdMember ownerMember);
  Future<void> updateHousehold(Household household);
  Future<void> deleteHousehold(String householdId);

  // User's household
  Future<String?> getUserHouseholdId(String userId);
  Stream<String?> watchUserHouseholdId(String userId);
  Future<void> setUserHouseholdId(String userId, String? householdId);

  // Member management
  Future<void> addMember(String householdId, HouseholdMember member);
  Future<void> updateMemberRole(String householdId, String memberId, HouseholdRole newRole);
  Future<void> removeMember(String householdId, String memberId);

  // Invite codes
  Future<InviteCode> generateInviteCode(String householdId, String createdBy);
  Future<InviteCode?> getInviteCodeByCode(String code);
  Future<void> markInviteCodeUsed(String householdId, String codeId);
  Future<List<InviteCode>> getActiveInviteCodes(String householdId);

  // Migration
  Future<void> migrateUserDataToHousehold({
    required String userId,
    required String householdId,
  });

  // Notifications
  Future<void> notifyOwnerOfNewMember({
    required String householdId,
    required String newMemberName,
  });

  Future<void> notifyOwnerOfMemberLeft({
    required String householdId,
    required String memberName,
  });

  // Username management
  Future<bool> isUsernameAvailable(String username);
  Future<void> registerUsername(String userId, String username);
  Future<String?> getUsernameByUserId(String userId);

  // User search
  Future<UserProfile?> findUserByUsername(String username);

  // Household requests
  Future<HouseholdRequest> createHouseholdRequest({
    required String senderId,
    required String senderUsername,
    required String? senderDisplayName,
    required String? senderPhotoUrl,
    required String receiverId,
    required String receiverUsername,
    required String householdId,
    required String householdName,
  });
  Future<List<HouseholdRequest>> getReceivedRequests(String userId);
  Stream<List<HouseholdRequest>> watchReceivedRequests(String userId);
  Future<List<HouseholdRequest>> getSentRequests(String userId);
  Stream<List<HouseholdRequest>> watchSentRequests(String userId);
  Future<HouseholdRequest?> getHouseholdRequest(String requestId);
  Future<void> acceptHouseholdRequest(String requestId);
  Future<void> rejectHouseholdRequest(String requestId);
  Future<void> cancelHouseholdRequest(String requestId);
  Future<bool> hasExistingRequest({
    required String senderId,
    required String receiverId,
  });
}
