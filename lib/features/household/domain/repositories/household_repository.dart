import '../entities/household.dart';
import '../entities/household_member.dart';
import '../entities/household_role.dart';
import '../entities/invite_code.dart';

/// Repository interface for household management operations.
///
/// This abstract class defines the contract for household data operations.
/// The concrete implementation ([HouseholdRepositoryImpl]) uses Firestore
/// as the data source.
///
/// ## Responsibilities
/// - **Household CRUD**: Create, read, update, delete households
/// - **Member Management**: Add/remove members, update roles
/// - **Invite Codes**: Generate and validate invite codes
/// - **Data Migration**: Move user data when joining a household
/// - **Notifications**: Alert owners of member changes
///
/// ## Usage
/// ```dart
/// final repository = ref.read(householdRepositoryProvider);
/// final household = await repository.getHousehold(householdId);
/// ```
abstract class HouseholdRepository {
  // ============================================
  // Household CRUD
  // ============================================

  /// Fetches a household by ID. Returns null if not found.
  Future<Household?> getHousehold(String householdId);

  /// Returns a real-time stream of household data.
  Stream<Household?> watchHousehold(String householdId);

  /// Creates a new household with the given owner.
  Future<Household> createHousehold(String name, String ownerId, HouseholdMember ownerMember);

  /// Updates an existing household's data.
  Future<void> updateHousehold(Household household);

  /// Deletes a household and all associated data.
  Future<void> deleteHousehold(String householdId);

  // ============================================
  // User-Household Association
  // ============================================

  /// Gets the household ID for a user. Returns null if user has no household.
  Future<String?> getUserHouseholdId(String userId);

  /// Returns a real-time stream of the user's household ID.
  Stream<String?> watchUserHouseholdId(String userId);

  /// Sets or clears the user's household association.
  Future<void> setUserHouseholdId(String userId, String? householdId);

  // ============================================
  // Member Management
  // ============================================

  /// Adds a new member to a household.
  Future<void> addMember(String householdId, HouseholdMember member);

  /// Updates a member's role within the household.
  Future<void> updateMemberRole(String householdId, String memberId, HouseholdRole newRole);

  /// Removes a member from the household.
  Future<void> removeMember(String householdId, String memberId);

  // ============================================
  // Invite Codes
  // ============================================

  /// Generates a new invite code for the household.
  Future<InviteCode> generateInviteCode(String householdId, String createdBy);

  /// Looks up an invite code by its string value.
  Future<InviteCode?> getInviteCodeByCode(String code);

  /// Marks an invite code as used (cannot be reused).
  Future<void> markInviteCodeUsed(String householdId, String codeId);

  /// Gets all active (unused, not expired) invite codes.
  Future<List<InviteCode>> getActiveInviteCodes(String householdId);

  // ============================================
  // Data Migration
  // ============================================

  /// Migrates a user's personal items to a household's shared storage.
  ///
  /// Called when a user joins a household for the first time.
  Future<void> migrateUserDataToHousehold({
    required String userId,
    required String householdId,
  });

  /// Generates a permanent invite code for households that don't have one.
  ///
  /// Called during migration for existing households created before
  /// the permanent invite code feature was added.
  Future<void> migrateHouseholdInviteCode(String householdId);

  // ============================================
  // Notifications
  // ============================================

  /// Notifies the household owner when a new member joins.
  Future<void> notifyOwnerOfNewMember({
    required String householdId,
    required String newMemberName,
  });

  /// Notifies the household owner when a member leaves.
  Future<void> notifyOwnerOfMemberLeft({
    required String householdId,
    required String memberName,
  });
}
