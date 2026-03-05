import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/datasources/household_firestore_datasource.dart';
import '../../data/repositories_impl/household_repository_impl.dart';
import '../../domain/entities/household.dart';
import '../../domain/entities/household_member.dart';
import '../../domain/entities/household_role.dart';
import '../../domain/entities/invite_code.dart';
import '../../domain/repositories/household_repository.dart';

// DataSource Provider
final householdDataSourceProvider = Provider<HouseholdFirestoreDataSource>((ref) {
  return HouseholdFirestoreDataSource();
});

// Repository Provider
final householdRepositoryProvider = Provider<HouseholdRepository>((ref) {
  final dataSource = ref.watch(householdDataSourceProvider);
  return HouseholdRepositoryImpl(dataSource);
});

// Current User's Household ID
final currentHouseholdIdProvider = StreamProvider<String?>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value(null);

  final repository = ref.watch(householdRepositoryProvider);
  return repository.watchUserHouseholdId(user.uid);
});

// Current Household
final currentHouseholdProvider = StreamProvider<Household?>((ref) {
  final householdIdAsync = ref.watch(currentHouseholdIdProvider);

  return householdIdAsync.when(
    data: (householdId) {
      if (householdId == null) return Stream.value(null);
      final repository = ref.watch(householdRepositoryProvider);
      return repository.watchHousehold(householdId);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

// Current User's Role in Household
final currentUserRoleProvider = Provider<HouseholdRole?>((ref) {
  final household = ref.watch(currentHouseholdProvider).value;
  final user = FirebaseAuth.instance.currentUser;

  if (household == null || user == null) return null;
  return household.getMemberRole(user.uid);
});

// Can current user edit items
final canEditProvider = Provider<bool>((ref) {
  final role = ref.watch(currentUserRoleProvider);
  return role?.canEdit ?? false;
});

// Can current user manage members
final canManageMembersProvider = Provider<bool>((ref) {
  final role = ref.watch(currentUserRoleProvider);
  return role?.canManageMembers ?? false;
});

// Household Members List
final householdMembersProvider = Provider<List<HouseholdMember>>((ref) {
  final household = ref.watch(currentHouseholdProvider).value;
  return household?.membersList ?? [];
});

// Active Invite Codes
final activeInviteCodesProvider = FutureProvider<List<InviteCode>>((ref) async {
  final householdId = ref.watch(currentHouseholdIdProvider).value;
  if (householdId == null) return [];

  final repository = ref.watch(householdRepositoryProvider);
  return repository.getActiveInviteCodes(householdId);
});

// Household Actions State
class HouseholdActionsState {
  final bool isLoading;
  final String? error;

  const HouseholdActionsState({
    this.isLoading = false,
    this.error,
  });

  HouseholdActionsState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return HouseholdActionsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Household Actions Notifier
class HouseholdActionsNotifier extends Notifier<HouseholdActionsState> {
  @override
  HouseholdActionsState build() {
    return const HouseholdActionsState();
  }

  HouseholdRepository get _repository => ref.read(householdRepositoryProvider);

  Future<Household?> createHousehold(String name) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      state = state.copyWith(error: '로그인이 필요합니다');
      return null;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final member = HouseholdMember(
        id: user.uid,
        role: HouseholdRole.owner,
        joinedAt: DateTime.now(),
        displayName: user.displayName,
        photoUrl: user.photoURL,
        email: user.email,
      );

      final household = await _repository.createHousehold(name, user.uid, member);
      await _repository.setUserHouseholdId(user.uid, household.id);

      // Migrate existing data
      await _repository.migrateUserDataToHousehold(
        userId: user.uid,
        householdId: household.id,
      );

      state = state.copyWith(isLoading: false);
      return household;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<bool> joinHouseholdWithCode(String code) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      state = state.copyWith(error: '로그인이 필요합니다');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final inviteCode = await _repository.getInviteCodeByCode(code.toUpperCase());
      if (inviteCode == null) {
        state = state.copyWith(isLoading: false, error: '유효하지 않은 초대 코드입니다');
        return false;
      }

      if (!inviteCode.isValid) {
        state = state.copyWith(isLoading: false, error: '만료된 초대 코드입니다');
        return false;
      }

      final member = HouseholdMember(
        id: user.uid,
        role: HouseholdRole.viewer, // Default role for invited users
        joinedAt: DateTime.now(),
        displayName: user.displayName,
        photoUrl: user.photoURL,
        email: user.email,
      );

      await _repository.addMember(inviteCode.householdId, member);
      await _repository.setUserHouseholdId(user.uid, inviteCode.householdId);
      await _repository.markInviteCodeUsed(inviteCode.householdId, inviteCode.id);

      // Notify owner of new member
      await _repository.notifyOwnerOfNewMember(
        householdId: inviteCode.householdId,
        newMemberName: user.displayName ?? user.email ?? '新しいメンバー',
      );

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<InviteCode?> generateInviteCode() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final householdId = await _repository.getUserHouseholdId(user.uid);
    if (householdId == null) return null;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final inviteCode = await _repository.generateInviteCode(householdId, user.uid);
      state = state.copyWith(isLoading: false);
      return inviteCode;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<bool> updateMemberRole(String memberId, HouseholdRole newRole) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final householdId = await _repository.getUserHouseholdId(user.uid);
    if (householdId == null) return false;

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updateMemberRole(householdId, memberId, newRole);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> removeMember(String memberId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final householdId = await _repository.getUserHouseholdId(user.uid);
    if (householdId == null) return false;

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.removeMember(householdId, memberId);
      await _repository.setUserHouseholdId(memberId, null);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> leaveHousehold() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final householdId = await _repository.getUserHouseholdId(user.uid);
    if (householdId == null) return false;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final household = await _repository.getHousehold(householdId);
      if (household == null) return false;

      // Check if user is the only member
      if (household.memberCount == 1) {
        // Delete the entire household
        await _repository.deleteHousehold(householdId);
      } else if (household.isOwner(user.uid)) {
        // Owner must transfer ownership first
        state = state.copyWith(isLoading: false, error: '소유권을 이전한 후 탈퇴할 수 있습니다');
        return false;
      } else {
        // Remove member from household
        await _repository.removeMember(householdId, user.uid);

        // Notify owner of member leaving
        await _repository.notifyOwnerOfMemberLeft(
          householdId: householdId,
          memberName: user.displayName ?? user.email ?? 'メンバー',
        );
      }

      await _repository.setUserHouseholdId(user.uid, null);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final householdActionsProvider =
    NotifierProvider<HouseholdActionsNotifier, HouseholdActionsState>(() {
  return HouseholdActionsNotifier();
});

// Auto-migration provider (creates household for existing users)
final autoMigrationProvider = FutureProvider<void>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final repository = ref.watch(householdRepositoryProvider);
  final householdId = await repository.getUserHouseholdId(user.uid);

  if (householdId == null) {
    // Auto-create household for existing users
    final member = HouseholdMember(
      id: user.uid,
      role: HouseholdRole.owner,
      joinedAt: DateTime.now(),
      displayName: user.displayName,
      photoUrl: user.photoURL,
      email: user.email,
    );

    final household = await repository.createHousehold(
      '나의 냉장고',
      user.uid,
      member,
    );

    await repository.setUserHouseholdId(user.uid, household.id);
    await repository.migrateUserDataToHousehold(
      userId: user.uid,
      householdId: household.id,
    );
  }
});
