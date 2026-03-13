import '../entities/household.dart';
import '../entities/household_member.dart';
import '../entities/household_role.dart';
import '../entities/invite_code.dart';

/// Household 관리를 위한 Repository 인터페이스
///
/// 책임:
/// - Household CRUD
/// - 멤버 관리
/// - 초대 코드 관리
/// - 데이터 마이그레이션
/// - 알림 전송
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
}
