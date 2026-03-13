import '../entities/household_role.dart';
import '../repositories/household_repository.dart';

class UpdateMemberRoleUseCase {
  final HouseholdRepository repository;

  UpdateMemberRoleUseCase(this.repository);

  Future<bool> call({
    required String userId,
    required String memberId,
    required HouseholdRole newRole,
  }) async {
    final householdId = await repository.getUserHouseholdId(userId);
    if (householdId == null) return false;

    await repository.updateMemberRole(householdId, memberId, newRole);
    return true;
  }
}
