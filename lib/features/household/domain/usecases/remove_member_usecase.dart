import '../repositories/household_repository.dart';

class RemoveMemberUseCase {
  final HouseholdRepository repository;

  RemoveMemberUseCase(this.repository);

  Future<bool> call({
    required String userId,
    required String memberId,
  }) async {
    final householdId = await repository.getUserHouseholdId(userId);
    if (householdId == null) return false;

    await repository.removeMember(householdId, memberId);
    await repository.setUserHouseholdId(memberId, null);
    return true;
  }
}
