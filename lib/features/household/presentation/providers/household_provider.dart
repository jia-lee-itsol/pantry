import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../auth/domain/entities/user_profile.dart';
import '../../data/datasources/household_firestore_datasource.dart';
import '../../data/repositories_impl/household_repository_impl.dart';
import '../../domain/entities/household.dart';
import '../../domain/entities/household_member.dart';
import '../../domain/entities/household_request.dart';
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

  // ============================================
  // Username Methods
  // ============================================

  /// Register a username for the current user
  Future<bool> registerUsername(String username) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      state = state.copyWith(error: '로그인이 필요합니다');
      return false;
    }

    // Validate username format (alphanumeric, 3-20 chars)
    final usernameRegex = RegExp(r'^[a-zA-Z0-9]{3,20}$');
    if (!usernameRegex.hasMatch(username)) {
      state = state.copyWith(error: '아이디는 영문과 숫자만 사용하여 3-20자로 입력해주세요');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.registerUsername(user.uid, username);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // ============================================
  // User Search Methods
  // ============================================

  /// Search for a user by username
  Future<UserProfile?> searchUserByUsername(String username) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final profile = await _repository.findUserByUsername(username);
      state = state.copyWith(isLoading: false);
      return profile;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  // ============================================
  // Household Request Methods
  // ============================================

  /// Send a household request to another user
  Future<bool> sendHouseholdRequest(UserProfile receiver) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      state = state.copyWith(error: '로그인이 필요합니다');
      return false;
    }

    // Get current user's username
    final senderUsername = await _repository.getUsernameByUserId(user.uid);
    if (senderUsername == null) {
      state = state.copyWith(error: '먼저 아이디를 등록해주세요');
      return false;
    }

    // Get current household
    final householdId = await _repository.getUserHouseholdId(user.uid);
    if (householdId == null) {
      state = state.copyWith(error: '가구가 없습니다');
      return false;
    }

    final household = await _repository.getHousehold(householdId);
    if (household == null) {
      state = state.copyWith(error: '가구를 찾을 수 없습니다');
      return false;
    }

    // Check if already a member
    if (household.isMember(receiver.id)) {
      state = state.copyWith(error: '이미 가구 멤버입니다');
      return false;
    }

    // Check if request already exists
    final existingRequest = await _repository.hasExistingRequest(
      senderId: user.uid,
      receiverId: receiver.id,
    );
    if (existingRequest) {
      state = state.copyWith(error: '이미 요청을 보냈습니다');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.createHouseholdRequest(
        senderId: user.uid,
        senderUsername: senderUsername,
        senderDisplayName: user.displayName,
        senderPhotoUrl: user.photoURL,
        receiverId: receiver.id,
        receiverUsername: receiver.username,
        householdId: householdId,
        householdName: household.name,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Accept a household request
  Future<bool> acceptRequest(String requestId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.acceptHouseholdRequest(requestId);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Reject a household request
  Future<bool> rejectRequest(String requestId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.rejectHouseholdRequest(requestId);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Cancel a sent request
  Future<bool> cancelRequest(String requestId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.cancelHouseholdRequest(requestId);
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

// ============================================
// Username Providers
// ============================================

// Current user's username
final currentUsernameProvider = FutureProvider<String?>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;

  final repository = ref.watch(householdRepositoryProvider);
  return repository.getUsernameByUserId(user.uid);
});

// Check if username is available
final usernameAvailabilityProvider =
    FutureProvider.family<bool, String>((ref, username) async {
  if (username.isEmpty) return false;
  final repository = ref.watch(householdRepositoryProvider);
  return repository.isUsernameAvailable(username);
});

// ============================================
// Household Request Providers
// ============================================

// Received requests (real-time)
final receivedRequestsProvider = StreamProvider<List<HouseholdRequest>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);

  final repository = ref.watch(householdRepositoryProvider);
  return repository.watchReceivedRequests(user.uid);
});

// Sent requests (real-time)
final sentRequestsProvider = StreamProvider<List<HouseholdRequest>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);

  final repository = ref.watch(householdRepositoryProvider);
  return repository.watchSentRequests(user.uid);
});

// Pending received requests count (for badge)
final pendingRequestsCountProvider = Provider<int>((ref) {
  final requests = ref.watch(receivedRequestsProvider).value ?? [];
  return requests.where((r) => r.isPending).length;
});
