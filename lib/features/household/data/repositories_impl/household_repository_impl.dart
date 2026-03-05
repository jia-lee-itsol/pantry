import '../../domain/entities/household.dart';
import '../../domain/entities/household_member.dart';
import '../../domain/entities/household_role.dart';
import '../../domain/entities/invite_code.dart';
import '../../domain/repositories/household_repository.dart';
import '../datasources/household_firestore_datasource.dart';

class HouseholdRepositoryImpl implements HouseholdRepository {
  final HouseholdFirestoreDataSource _dataSource;

  HouseholdRepositoryImpl(this._dataSource);

  @override
  Future<Household?> getHousehold(String householdId) {
    return _dataSource.getHousehold(householdId);
  }

  @override
  Stream<Household?> watchHousehold(String householdId) {
    return _dataSource.watchHousehold(householdId);
  }

  @override
  Future<Household> createHousehold(
    String name,
    String ownerId,
    HouseholdMember ownerMember,
  ) {
    return _dataSource.createHousehold(name, ownerId, ownerMember);
  }

  @override
  Future<void> updateHousehold(Household household) {
    return _dataSource.updateHousehold(household);
  }

  @override
  Future<void> deleteHousehold(String householdId) {
    return _dataSource.deleteHousehold(householdId);
  }

  @override
  Future<String?> getUserHouseholdId(String userId) {
    return _dataSource.getUserHouseholdId(userId);
  }

  @override
  Stream<String?> watchUserHouseholdId(String userId) {
    return _dataSource.watchUserHouseholdId(userId);
  }

  @override
  Future<void> setUserHouseholdId(String userId, String? householdId) {
    return _dataSource.setUserHouseholdId(userId, householdId);
  }

  @override
  Future<void> addMember(String householdId, HouseholdMember member) {
    return _dataSource.addMember(householdId, member);
  }

  @override
  Future<void> updateMemberRole(
    String householdId,
    String memberId,
    HouseholdRole newRole,
  ) {
    return _dataSource.updateMemberRole(householdId, memberId, newRole);
  }

  @override
  Future<void> removeMember(String householdId, String memberId) {
    return _dataSource.removeMember(householdId, memberId);
  }

  @override
  Future<InviteCode> generateInviteCode(String householdId, String createdBy) {
    return _dataSource.generateInviteCode(householdId, createdBy);
  }

  @override
  Future<InviteCode?> getInviteCodeByCode(String code) {
    return _dataSource.getInviteCodeByCode(code);
  }

  @override
  Future<void> markInviteCodeUsed(String householdId, String codeId) {
    return _dataSource.markInviteCodeUsed(householdId, codeId);
  }

  @override
  Future<List<InviteCode>> getActiveInviteCodes(String householdId) {
    return _dataSource.getActiveInviteCodes(householdId);
  }

  @override
  Future<void> migrateUserDataToHousehold({
    required String userId,
    required String householdId,
  }) {
    return _dataSource.migrateUserDataToHousehold(
      userId: userId,
      householdId: householdId,
    );
  }

  @override
  Future<void> notifyOwnerOfNewMember({
    required String householdId,
    required String newMemberName,
  }) {
    return _dataSource.notifyOwnerOfNewMember(
      householdId: householdId,
      newMemberName: newMemberName,
    );
  }

  @override
  Future<void> notifyOwnerOfMemberLeft({
    required String householdId,
    required String memberName,
  }) {
    return _dataSource.notifyOwnerOfMemberLeft(
      householdId: householdId,
      memberName: memberName,
    );
  }
}
