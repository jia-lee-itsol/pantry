import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/design/widgets/app_scaffold.dart';
import '../../../../core/design/spacing.dart';
import '../../../../core/services/backup_service.dart';
import '../../../../core/services/notification_settings_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _expiryNotificationsEnabled = true;
  bool _stockNotificationsEnabled = true;
  final _backupService = BackupService();
  final _notificationSettingsService = NotificationSettingsService();
  bool _isBackingUp = false;
  bool _isRestoring = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    try {
      final expiryEnabled = await _notificationSettingsService.getExpiryNotificationsEnabled();
      final stockEnabled = await _notificationSettingsService.getStockNotificationsEnabled();
      if (mounted) {
        setState(() {
          _expiryNotificationsEnabled = expiryEnabled;
          _stockNotificationsEnabled = stockEnabled;
        });
      }
    } catch (e) {
      // 에러 발생 시 기본값 유지
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: Text(AppStrings.settings),
      body: ListView(
        children: [
          // 通知設定セクション
          _buildSectionHeader('通知設定'),
          _buildSwitchTile(
            title: '賞味期限通知',
            subtitle: '期限間近の商品の通知を受け取ります',
            icon: Icons.notifications_outlined,
            value: _expiryNotificationsEnabled,
            onChanged: (value) async {
              setState(() {
                _expiryNotificationsEnabled = value;
              });
              await _notificationSettingsService.setExpiryNotificationsEnabled(value);
            },
          ),
          _buildSwitchTile(
            title: '備蓄品通知',
            subtitle: '備蓄品の在庫不足時に通知を受け取ります',
            icon: Icons.inventory_2_outlined,
            value: _stockNotificationsEnabled,
            onChanged: (value) async {
              setState(() {
                _stockNotificationsEnabled = value;
              });
              await _notificationSettingsService.setStockNotificationsEnabled(value);
            },
          ),

          const SizedBox(height: AppSpacing.lg),

          // 카테고리 관리 섹션
          _buildSectionHeader('カテゴリ管理'),
          _buildListTile(
            title: 'カテゴリ管理',
            subtitle: '商品カテゴリの追加、修正、削除',
            icon: Icons.category_outlined,
            onTap: () {
              context.push('/category-management');
            },
          ),

          const SizedBox(height: AppSpacing.lg),

          // 데이터 관리 섹션
          _buildSectionHeader('データ管理'),
          _buildListTile(
            title: 'キャッシュ削除',
            subtitle: 'アプリのキャッシュデータを削除します',
            icon: Icons.delete_outline,
            onTap: () {
              _showCacheDeleteDialog(context);
            },
          ),
          _buildListTile(
            title: 'データバックアップ',
            subtitle: _isBackingUp
                ? 'バックアップ中...'
                : 'データをクラウドにバックアップします',
            icon: Icons.cloud_upload_outlined,
            onTap: _isBackingUp
                ? () {}
                : () {
                    _showBackupDialog(context);
                  },
          ),
          _buildListTile(
            title: 'データ復元',
            subtitle: _isRestoring
                ? '復元中...'
                : 'バックアップしたデータを復元します',
            icon: Icons.cloud_download_outlined,
            onTap: _isRestoring
                ? () {}
                : () {
                    _showRestoreDialog(context);
                  },
          ),

          const SizedBox(height: AppSpacing.lg),

          // アプリ情報セクション
          _buildSectionHeader('アプリ情報'),
          _buildListTile(
            title: 'バージョン情報',
            subtitle: '現在のバージョン: ${AppStrings.appVersion}',
            icon: Icons.info_outline,
            onTap: () {
              _showVersionInfoDialog(context);
            },
          ),
          _buildListTile(
            title: '利用規約',
            subtitle: 'サービス利用規約を確認します',
            icon: Icons.description_outlined,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('利用規約ページは準備中です。')),
              );
            },
          ),
          _buildListTile(
            title: 'プライバシーポリシー',
            subtitle: 'プライバシーポリシーを確認します',
            icon: Icons.privacy_tip_outlined,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('プライバシーポリシーページは準備中です。')),
              );
            },
          ),

          const SizedBox(height: AppSpacing.lg),

          // アカウントセクション
          _buildSectionHeader('アカウント'),
          _buildListTile(
            title: 'ログアウト',
            subtitle: 'アカウントからログアウトします',
            icon: Icons.logout,
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
        ),
        secondary: Icon(icon),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showCacheDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('キャッシュ削除'),
        content: const Text('アプリのキャッシュデータを削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('キャッシュを削除しました。')));
            },
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }

  void _showVersionInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('アプリ情報'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('アプリ名: ${AppStrings.appName}'),
            const SizedBox(height: AppSpacing.sm),
            Text('バージョン: ${AppStrings.appVersion}'),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Pantryは冷蔵庫の在庫管理と備蓄品管理を助けるアプリです。',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('確認'),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('データバックアップ'),
        content: const Text('すべてのデータをクラウドにバックアップしますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              setState(() {
                _isBackingUp = true;
              });

              try {
                await _backupService.backupAllData();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('バックアップが完了しました。'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('バックアップに失敗しました: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() {
                    _isBackingUp = false;
                  });
                }
              }
            },
            child: const Text('バックアップ'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('データ復元'),
        content: const Text(
          'バックアップしたデータで現在のデータを上書きします。\nこの操作は取り消せません。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();

              // 백업 데이터 존재 여부 확인
              final hasBackup = await _backupService.hasBackupData();
              if (!hasBackup) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('バックアップデータが見つかりません。'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
                return;
              }

              // 확인 다이얼로그 표시
              final confirm = await showDialog<bool>(
                context: context,
                builder: (confirmContext) => AlertDialog(
                  title: const Text('確認'),
                  content: const Text('本当にデータを復元しますか？'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(confirmContext).pop(false),
                      child: const Text(AppStrings.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(confirmContext).pop(true),
                      child: const Text(
                        '復元',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm != true) return;

              setState(() {
                _isRestoring = true;
              });

              try {
                await _backupService.restoreAllData();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('データの復元が完了しました。アプリを再起動してください。'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 5),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('復元に失敗しました: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() {
                    _isRestoring = false;
                  });
                }
              }
            },
            child: const Text(
              '復元',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ログアウト'),
        content: const Text('本当にログアウトしますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final signOutUseCase = ref.read(signOutUseCaseProvider);
                await signOutUseCase();
                if (context.mounted) {
                  context.go('/login');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('ログアウトに失敗しました: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'ログアウト',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
