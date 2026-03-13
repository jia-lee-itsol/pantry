import '../entities/household.dart';
import '../entities/household_member.dart';
import '../repositories/household_repository.dart';

class CreateHouseholdUseCase {
  final HouseholdRepository repository;

  CreateHouseholdUseCase(this.repository);

  Future<Household> call({
    required String name,
    required String userId,
    required HouseholdMember member,
  }) async {
    final household = await repository.createHousehold(name, userId, member);
    await repository.setUserHouseholdId(userId, household.id);
    await repository.migrateUserDataToHousehold(
      userId: userId,
      householdId: household.id,
    );
    return household;
  }
}
