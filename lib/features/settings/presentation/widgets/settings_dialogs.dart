import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/design/spacing.dart';
import '../../../../core/services/backup_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SettingsDialogs {
  static void showCacheDeleteDialog(BuildContext context) {
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('キャッシュを削除しました。')),
              );
            },
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }

  static void showVersionInfoDialog(BuildContext context) {
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

  static void showBackupDialog(
    BuildContext context,
    BackupService backupService,
    VoidCallback onBackupStart,
    VoidCallback onBackupEnd,
  ) {
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
              onBackupStart();

              try {
                await backupService.backupAllData();
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
                onBackupEnd();
              }
            },
            child: const Text('バックアップ'),
          ),
        ],
      ),
    );
  }

  static void showRestoreDialog(
    BuildContext context,
    BackupService backupService,
    VoidCallback onRestoreStart,
    VoidCallback onRestoreEnd,
  ) {
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

              final hasBackup = await backupService.hasBackupData();
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

              if (!context.mounted) return;

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

              if (confirm != true || !context.mounted) return;

              onRestoreStart();

              try {
                await backupService.restoreAllData();
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
                onRestoreEnd();
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

  static void showLogoutDialog(BuildContext context, WidgetRef ref) {
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

  static void showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('アカウント削除'),
        content: const Text(
          'アカウントを削除すると、すべてのデータが完全に削除され、復元できません。\n\n本当に削除しますか？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();

              final confirm = await showDialog<bool>(
                context: context,
                builder: (confirmContext) => AlertDialog(
                  title: const Text('最終確認'),
                  content: const Text(
                    'この操作は取り消せません。\nアカウントを完全に削除してもよろしいですか？',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(confirmContext).pop(false),
                      child: const Text(AppStrings.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(confirmContext).pop(true),
                      child: const Text(
                        '削除する',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm != true) return;

              try {
                final deleteAccountUseCase =
                    ref.read(deleteAccountUseCaseProvider);
                await deleteAccountUseCase();
                if (context.mounted) {
                  context.go('/login');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('アカウントが削除されました。'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('アカウント削除に失敗しました: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              '削除',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
