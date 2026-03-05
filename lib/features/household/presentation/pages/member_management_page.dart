import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/household_member.dart';
import '../../domain/entities/household_role.dart';
import '../providers/household_provider.dart';

class MemberManagementPage extends ConsumerWidget {
  const MemberManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(householdMembersProvider);
    final canManage = ref.watch(canManageMembersProvider);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('멤버 관리'),
      ),
      body: members.isEmpty
          ? const Center(child: Text('멤버가 없습니다'))
          : ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                final isCurrentUser = member.id == currentUserId;

                return _MemberListTile(
                  member: member,
                  isCurrentUser: isCurrentUser,
                  canManage: canManage && !isCurrentUser,
                  onRoleChanged: (newRole) {
                    ref
                        .read(householdActionsProvider.notifier)
                        .updateMemberRole(member.id, newRole);
                  },
                  onRemove: () {
                    _showRemoveConfirmDialog(context, ref, member);
                  },
                );
              },
            ),
    );
  }

  void _showRemoveConfirmDialog(
    BuildContext context,
    WidgetRef ref,
    HouseholdMember member,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('멤버 내보내기'),
        content: Text('${member.displayName ?? '이 멤버'}님을 가구에서 내보내시겠습니까?'),
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
            onPressed: () {
              Navigator.pop(context);
              ref.read(householdActionsProvider.notifier).removeMember(member.id);
            },
            child: const Text('내보내기'),
          ),
        ],
      ),
    );
  }
}

class _MemberListTile extends StatelessWidget {
  final HouseholdMember member;
  final bool isCurrentUser;
  final bool canManage;
  final Function(HouseholdRole) onRoleChanged;
  final VoidCallback onRemove;

  const _MemberListTile({
    required this.member,
    required this.isCurrentUser,
    required this.canManage,
    required this.onRoleChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage:
            member.photoUrl != null ? NetworkImage(member.photoUrl!) : null,
        child: member.photoUrl == null
            ? Text(
                (member.displayName ?? member.email ?? '?')[0].toUpperCase(),
              )
            : null,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              member.displayName ?? member.email ?? '알 수 없음',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isCurrentUser)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '나',
                style: TextStyle(fontSize: 12, color: Colors.blue),
              ),
            ),
        ],
      ),
      subtitle: Text(member.role.displayName),
      trailing: canManage
          ? PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'remove') {
                  onRemove();
                } else {
                  final newRole = HouseholdRole.fromString(value);
                  onRoleChanged(newRole);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'owner',
                  child: ListTile(
                    leading: Icon(Icons.star),
                    title: Text('소유자'),
                    subtitle: Text('모든 권한'),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
                const PopupMenuItem(
                  value: 'editor',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('편집자'),
                    subtitle: Text('상품 추가/수정/삭제'),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
                const PopupMenuItem(
                  value: 'viewer',
                  child: ListTile(
                    leading: Icon(Icons.visibility),
                    title: Text('조회자'),
                    subtitle: Text('조회만 가능'),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'remove',
                  child: ListTile(
                    leading: Icon(Icons.person_remove, color: Colors.red),
                    title: Text('내보내기', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
              ],
            )
          : _RoleBadge(role: member.role),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final HouseholdRole role;

  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (role) {
      case HouseholdRole.owner:
        color = Colors.amber;
        icon = Icons.star;
        break;
      case HouseholdRole.editor:
        color = Colors.blue;
        icon = Icons.edit;
        break;
      case HouseholdRole.viewer:
        color = Colors.grey;
        icon = Icons.visibility;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            role.displayName,
            style: TextStyle(color: color, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
