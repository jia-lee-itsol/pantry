import '../entities/invite_code.dart';
import '../repositories/household_repository.dart';

class GenerateInviteCodeUseCase {
  final HouseholdRepository repository;

  GenerateInviteCodeUseCase(this.repository);

  Future<InviteCode?> call({
    required String userId,
  }) async {
    final householdId = await repository.getUserHouseholdId(userId);
    if (householdId == null) return null;

    return repository.generateInviteCode(householdId, userId);
  }
}
