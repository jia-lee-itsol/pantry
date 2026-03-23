import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../auth/domain/entities/user_profile.dart';
import '../../domain/entities/household.dart';
import '../../domain/entities/household_member.dart';
import '../../domain/entities/household_request.dart';
import '../../domain/entities/household_role.dart';
import '../../domain/entities/invite_code.dart';
import '../../domain/repositories/household_repository.dart';
import '../../domain/repositories/username_repository.dart';
import '../../domain/repositories/household_request_repository.dart';
import '../../domain/usecases/register_username_usecase.dart';
import '../../domain/usecases/send_household_request_usecase.dart';
import '../../domain/usecases/accept_household_request_usecase.dart';
import '../../domain/usecases/reject_household_request_usecase.dart';
import '../../domain/usecases/cancel_household_request_usecase.dart';
import '../../domain/usecases/notify_user_usecase.dart';
import '../../domain/usecases/create_household_usecase.dart';
import '../../domain/usecases/join_household_usecase.dart';
import '../../domain/usecases/generate_invite_code_usecase.dart';
import '../../domain/usecases/update_member_role_usecase.dart';
import '../../domain/usecases/remove_member_usecase.dart';
import '../../domain/usecases/leave_household_usecase.dart';
import '../../domain/usecases/search_user_usecase.dart';
import '../../../../core/services/household_service.dart';

// ============================================
// Repository Providers (uses core services)
// ============================================

final householdRepositoryProvider = Provider<HouseholdRepository>((ref) {
  return ref.watch(householdServiceProvider);
});

final usernameRepositoryProvider = Provider<UsernameRepository>((ref) {
  return ref.watch(usernameServiceProvider);
});

final householdRequestRepositoryProvider = Provider<HouseholdRequestRepository>((ref) {
  return ref.watch(householdRequestServiceProvider);
});

// ============================================
// UseCase Providers
// ============================================

final notifyUserUseCaseProvider = Provider<NotifyUserUseCase>((ref) {
  return NotifyUserUseCase();
});

final registerUsernameUseCaseProvider = Provider<RegisterUsernameUseCase>((ref) {
  final repository = ref.watch(usernameRepositoryProvider);
  return RegisterUsernameUseCase(repository);
});

final sendHouseholdRequestUseCaseProvider = Provider<SendHouseholdRequestUseCase>((ref) {
  return SendHouseholdRequestUseCase(
    householdRepository: ref.watch(householdRepositoryProvider),
    requestRepository: ref.watch(householdRequestRepositoryProvider),
    usernameRepository: ref.watch(usernameRepositoryProvider),
    notifyUserUseCase: ref.watch(notifyUserUseCaseProvider),
  );
});

final acceptHouseholdRequestUseCaseProvider = Provider<AcceptHouseholdRequestUseCase>((ref) {
  return AcceptHouseholdRequestUseCase(
    householdRepository: ref.watch(householdRepositoryProvider),
    requestRepository: ref.watch(householdRequestRepositoryProvider),
    notifyUserUseCase: ref.watch(notifyUserUseCaseProvider),
  );
});

final rejectHouseholdRequestUseCaseProvider = Provider<RejectHouseholdRequestUseCase>((ref) {
  final repository = ref.watch(householdRequestRepositoryProvider);
  return RejectHouseholdRequestUseCase(repository);
});

final cancelHouseholdRequestUseCaseProvider = Provider<CancelHouseholdRequestUseCase>((ref) {
  final repository = ref.watch(householdRequestRepositoryProvider);
  return CancelHouseholdRequestUseCase(repository);
});

final createHouseholdUseCaseProvider = Provider<CreateHouseholdUseCase>((ref) {
  final repository = ref.watch(householdRepositoryProvider);
  return CreateHouseholdUseCase(repository);
});

final joinHouseholdUseCaseProvider = Provider<JoinHouseholdUseCase>((ref) {
  final repository = ref.watch(householdRepositoryProvider);
  return JoinHouseholdUseCase(repository);
});

final generateInviteCodeUseCaseProvider = Provider<GenerateInviteCodeUseCase>((ref) {
  final repository = ref.watch(householdRepositoryProvider);
  return GenerateInviteCodeUseCase(repository);
});

final updateMemberRoleUseCaseProvider = Provider<UpdateMemberRoleUseCase>((ref) {
  final repository = ref.watch(householdRepositoryProvider);
  return UpdateMemberRoleUseCase(repository);
});

final removeMemberUseCaseProvider = Provider<RemoveMemberUseCase>((ref) {
  final repository = ref.watch(householdRepositoryProvider);
  return RemoveMemberUseCase(repository);
});

final leaveHouseholdUseCaseProvider = Provider<LeaveHouseholdUseCase>((ref) {
  final repository = ref.watch(householdRepositoryProvider);
  return LeaveHouseholdUseCase(repository);
});

final searchUserUseCaseProvider = Provider<SearchUserUseCase>((ref) {
  final repository = ref.watch(usernameRepositoryProvider);
  return SearchUserUseCase(repository);
});

// ============================================
// Auth State Provider
// ============================================

final currentFirebaseUserProvider = Provider<User?>((ref) {
  return FirebaseAuth.instance.currentUser;
});

// ============================================
// Household State Providers
// ============================================

final currentHouseholdIdProvider = StreamProvider<String?>((ref) {
  final user = ref.watch(currentFirebaseUserProvider);
  if (user == null) return Stream.value(null);

  final repository = ref.watch(householdRepositoryProvider);
  return repository.watchUserHouseholdId(user.uid);
});

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

final currentUserRoleProvider = Provider<HouseholdRole?>((ref) {
  final household = ref.watch(currentHouseholdProvider).value;
  final user = ref.watch(currentFirebaseUserProvider);

  if (household == null || user == null) return null;
  return household.getMemberRole(user.uid);
});

final canEditProvider = Provider<bool>((ref) {
  final role = ref.watch(currentUserRoleProvider);
  return role?.canEdit ?? false;
});

final canManageMembersProvider = Provider<bool>((ref) {
  final role = ref.watch(currentUserRoleProvider);
  return role?.canManageMembers ?? false;
});

final householdMembersProvider = Provider<List<HouseholdMember>>((ref) {
  final household = ref.watch(currentHouseholdProvider).value;
  return household?.membersList ?? [];
});

final activeInviteCodesProvider = FutureProvider<List<InviteCode>>((ref) async {
  final householdId = ref.watch(currentHouseholdIdProvider).value;
  if (householdId == null) return [];

  final repository = ref.watch(householdRepositoryProvider);
  return repository.getActiveInviteCodes(householdId);
});

// ============================================
// Username Providers
// ============================================

final currentUsernameProvider = FutureProvider<String?>((ref) async {
  final user = ref.watch(currentFirebaseUserProvider);
  if (user == null) return null;

  final repository = ref.watch(usernameRepositoryProvider);
  return repository.getUsernameByUserId(user.uid);
});

final usernameAvailabilityProvider = FutureProvider.family<bool, String>((ref, username) async {
  if (username.isEmpty) return false;
  final repository = ref.watch(usernameRepositoryProvider);
  return repository.isUsernameAvailable(username);
});

// ============================================
// Household Request Providers
// ============================================

final receivedRequestsProvider = StreamProvider<List<HouseholdRequest>>((ref) {
  final user = ref.watch(currentFirebaseUserProvider);
  if (user == null) return Stream.value([]);

  final repository = ref.watch(householdRequestRepositoryProvider);
  return repository.watchReceivedRequests(user.uid);
});

final sentRequestsProvider = StreamProvider<List<HouseholdRequest>>((ref) {
  final user = ref.watch(currentFirebaseUserProvider);
  if (user == null) return Stream.value([]);

  final repository = ref.watch(householdRequestRepositoryProvider);
  return repository.watchSentRequests(user.uid);
});

final pendingRequestsCountProvider = Provider<int>((ref) {
  final requests = ref.watch(receivedRequestsProvider).value ?? [];
  return requests.where((r) => r.isPending).length;
});

// ============================================
// Actions State & Notifier
// ============================================

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

class HouseholdActionsNotifier extends Notifier<HouseholdActionsState> {
  @override
  HouseholdActionsState build() {
    return const HouseholdActionsState();
  }

  User? get _currentUser => ref.read(currentFirebaseUserProvider);

  // ============================================
  // Household Actions (via UseCases)
  // ============================================

  Future<Household?> createHousehold(String name) async {
    final user = _currentUser;
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

      final useCase = ref.read(createHouseholdUseCaseProvider);
      final household = await useCase(
        name: name,
        userId: user.uid,
        member: member,
      );

      state = state.copyWith(isLoading: false);
      return household;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<bool> joinHouseholdWithCode(String code) async {
    final user = _currentUser;
    if (user == null) {
      state = state.copyWith(error: '로그인이 필요합니다');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final member = HouseholdMember(
        id: user.uid,
        role: HouseholdRole.viewer,
        joinedAt: DateTime.now(),
        displayName: user.displayName,
        photoUrl: user.photoURL,
        email: user.email,
      );

      final useCase = ref.read(joinHouseholdUseCaseProvider);
      await useCase(
        code: code,
        userId: user.uid,
        member: member,
        memberDisplayName: user.displayName ?? user.email ?? '新しいメンバー',
      );

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<InviteCode?> generateInviteCode() async {
    final user = _currentUser;
    if (user == null) return null;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final useCase = ref.read(generateInviteCodeUseCaseProvider);
      final inviteCode = await useCase(userId: user.uid);
      state = state.copyWith(isLoading: false);
      return inviteCode;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<bool> updateMemberRole(String memberId, HouseholdRole newRole) async {
    final user = _currentUser;
    if (user == null) return false;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final useCase = ref.read(updateMemberRoleUseCaseProvider);
      final result = await useCase(
        userId: user.uid,
        memberId: memberId,
        newRole: newRole,
      );
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> removeMember(String memberId) async {
    final user = _currentUser;
    if (user == null) return false;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final useCase = ref.read(removeMemberUseCaseProvider);
      final result = await useCase(
        userId: user.uid,
        memberId: memberId,
      );
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> leaveHousehold() async {
    final user = _currentUser;
    if (user == null) return false;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final useCase = ref.read(leaveHouseholdUseCaseProvider);
      final result = await useCase(
        userId: user.uid,
        userDisplayName: user.displayName,
        userEmail: user.email,
      );
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // ============================================
  // Username Actions (via UseCase)
  // ============================================

  Future<bool> registerUsername(String username) async {
    final user = _currentUser;
    if (user == null) {
      state = state.copyWith(error: '로그인이 필요합니다');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final useCase = ref.read(registerUsernameUseCaseProvider);
      await useCase(userId: user.uid, username: username);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // ============================================
  // User Search Actions (via UseCase)
  // ============================================

  Future<UserProfile?> searchUserByUsername(String username) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final useCase = ref.read(searchUserUseCaseProvider);
      final profile = await useCase(username);
      state = state.copyWith(isLoading: false);
      return profile;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  // ============================================
  // Household Request Actions (via UseCase)
  // ============================================

  Future<bool> sendHouseholdRequest(UserProfile receiver) async {
    final user = _currentUser;
    if (user == null) {
      state = state.copyWith(error: '로그인이 필요합니다');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final useCase = ref.read(sendHouseholdRequestUseCaseProvider);
      await useCase(
        senderId: user.uid,
        senderDisplayName: user.displayName,
        senderPhotoUrl: user.photoURL,
        receiver: receiver,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> acceptRequest(String requestId) async {
    final user = _currentUser;
    if (user == null) {
      state = state.copyWith(error: '로그인이 필요합니다');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final useCase = ref.read(acceptHouseholdRequestUseCaseProvider);
      await useCase(
        requestId: requestId,
        receiverId: user.uid,
        receiverDisplayName: user.displayName,
        receiverPhotoUrl: user.photoURL,
        receiverEmail: user.email,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> rejectRequest(String requestId) async {
    final user = _currentUser;
    if (user == null) {
      state = state.copyWith(error: '로그인이 필요합니다');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final useCase = ref.read(rejectHouseholdRequestUseCaseProvider);
      await useCase(requestId: requestId, receiverId: user.uid);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> cancelRequest(String requestId) async {
    final user = _currentUser;
    if (user == null) {
      state = state.copyWith(error: '로그인이 필요합니다');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final useCase = ref.read(cancelHouseholdRequestUseCaseProvider);
      await useCase(requestId: requestId, senderId: user.uid);
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

// ============================================
// Auto-migration Provider
// ============================================

final autoMigrationProvider = FutureProvider<void>((ref) async {
  final user = ref.watch(currentFirebaseUserProvider);
  if (user == null) return;

  final repository = ref.watch(householdRepositoryProvider);
  final householdId = await repository.getUserHouseholdId(user.uid);

  if (householdId == null) {
    // New user: create household with invite code
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
  } else {
    // Existing user: migrate invite code if needed
    await repository.migrateHouseholdInviteCode(householdId);
  }
});
