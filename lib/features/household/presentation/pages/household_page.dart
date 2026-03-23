import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/household_provider.dart';

class HouseholdPage extends ConsumerWidget {
  const HouseholdPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final householdAsync = ref.watch(currentHouseholdProvider);
    final canManage = ref.watch(canManageMembersProvider);
    final members = ref.watch(householdMembersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('가족 공유'),
      ),
      body: householdAsync.when(
        data: (household) {
          if (household == null) {
            return _buildNoHouseholdView(context, ref);
          }
          return _buildHouseholdView(
            context,
            ref,
            householdName: household.name,
            memberCount: members.length,
            canManage: canManage,
            inviteCode: household.inviteCode,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('오류: $error')),
      ),
    );
  }

  Widget _buildNoHouseholdView(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.home_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 24),
          const Text(
            '아직 가구에 가입되지 않았습니다',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            '새 가구를 만들거나 초대 코드로 가입하세요',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showCreateHouseholdDialog(context, ref),
              child: const Text('새 가구 만들기'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.push('/household/join'),
              child: const Text('초대 코드로 가입'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHouseholdView(
    BuildContext context,
    WidgetRef ref, {
    required String householdName,
    required int memberCount,
    required bool canManage,
    required String inviteCode,
  }) {
    final pendingCount = ref.watch(pendingRequestsCountProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 가구 정보 카드
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.home, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            householdName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '멤버 $memberCount명',
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 초대 코드 카드
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '내 초대 코드',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        inviteCode,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: inviteCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('초대 코드가 복사되었습니다')),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.qr_code),
                      onPressed: () => context.push('/household/invite'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '이 코드를 공유하여 다른 사람을 초대하세요',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 받은 요청 (배지 표시)
        ListTile(
          leading: Badge(
            isLabelVisible: pendingCount > 0,
            label: Text('$pendingCount'),
            child: const Icon(Icons.mail_outline),
          ),
          title: const Text('받은 초대 요청'),
          subtitle: Text(pendingCount > 0
              ? '$pendingCount개의 새 요청'
              : '받은 요청 확인'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/household/requests'),
        ),
        const Divider(),

        ListTile(
          leading: const Icon(Icons.people),
          title: const Text('멤버 관리'),
          subtitle: const Text('멤버 목록 보기 및 역할 변경'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/household/members'),
        ),
        if (canManage) ...[
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person_search),
            title: const Text('아이디로 초대'),
            subtitle: const Text('아이디를 검색하여 초대'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/household/search-user'),
          ),
        ],
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('가구 탈퇴', style: TextStyle(color: Colors.red)),
          subtitle: const Text('이 가구에서 나가기'),
          onTap: () => _showLeaveConfirmDialog(context, ref),
        ),
      ],
    );
  }

  void _showCreateHouseholdDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: '나의 냉장고');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 가구 만들기'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '가구 이름',
            hintText: '예: 우리 집',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;

              Navigator.pop(context);
              await ref.read(householdActionsProvider.notifier).createHousehold(name);
            },
            child: const Text('만들기'),
          ),
        ],
      ),
    );
  }

  void _showLeaveConfirmDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('가구 탈퇴'),
        content: const Text('정말로 이 가구에서 나가시겠습니까?\n\n혼자인 경우 모든 데이터가 삭제됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(householdActionsProvider.notifier).leaveHousehold();
            },
            child: const Text('탈퇴'),
          ),
        ],
      ),
    );
  }
}
