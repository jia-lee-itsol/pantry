import '../repositories/household_repository.dart';

class LeaveHouseholdUseCase {
  final HouseholdRepository repository;

  LeaveHouseholdUseCase(this.repository);

  Future<bool> call({
    required String userId,
    required String? userDisplayName,
    required String? userEmail,
  }) async {
    final householdId = await repository.getUserHouseholdId(userId);
    if (householdId == null) return false;

    final household = await repository.getHousehold(householdId);
    if (household == null) return false;

    if (household.memberCount == 1) {
      await repository.deleteHousehold(householdId);
    } else if (household.isOwner(userId)) {
      throw Exception('소유권을 이전한 후 탈퇴할 수 있습니다');
    } else {
      await repository.removeMember(householdId, userId);
      await repository.notifyOwnerOfMemberLeft(
        householdId: householdId,
        memberName: userDisplayName ?? userEmail ?? 'メンバー',
      );
    }

    await repository.setUserHouseholdId(userId, null);
    return true;
  }
}
