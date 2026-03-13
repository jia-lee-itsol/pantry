import '../entities/household_member.dart';
import '../repositories/household_repository.dart';

class JoinHouseholdUseCase {
  final HouseholdRepository repository;

  JoinHouseholdUseCase(this.repository);

  Future<bool> call({
    required String code,
    required String userId,
    required HouseholdMember member,
    required String memberDisplayName,
  }) async {
    final inviteCode = await repository.getInviteCodeByCode(code.toUpperCase());
    if (inviteCode == null) {
      throw Exception('유효하지 않은 초대 코드입니다');
    }

    if (!inviteCode.isValid) {
      throw Exception('만료된 초대 코드입니다');
    }

    await repository.addMember(inviteCode.householdId, member);
    await repository.setUserHouseholdId(userId, inviteCode.householdId);
    await repository.markInviteCodeUsed(inviteCode.householdId, inviteCode.id);

    await repository.notifyOwnerOfNewMember(
      householdId: inviteCode.householdId,
      newMemberName: memberDisplayName,
    );

    return true;
  }
}
