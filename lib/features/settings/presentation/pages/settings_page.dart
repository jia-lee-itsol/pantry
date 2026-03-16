import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/design/widgets/app_scaffold.dart';
import '../../../../core/design/spacing.dart';
import '../../../../core/services/backup_service.dart';
import '../../../../core/services/notification_settings_service.dart';
import '../widgets/settings_section_header.dart';
import '../widgets/settings_switch_tile.dart';
import '../widgets/settings_list_tile.dart';
import '../widgets/settings_dialogs.dart';

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
      final expiryEnabled =
          await _notificationSettingsService.getExpiryNotificationsEnabled();
      final stockEnabled =
          await _notificationSettingsService.getStockNotificationsEnabled();
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
          _buildNotificationSection(),
          const SizedBox(height: AppSpacing.lg),
          _buildCategorySection(),
          const SizedBox(height: AppSpacing.lg),
          _buildFamilySharingSection(),
          const SizedBox(height: AppSpacing.lg),
          _buildDataManagementSection(),
          const SizedBox(height: AppSpacing.lg),
          _buildAppInfoSection(),
          const SizedBox(height: AppSpacing.lg),
          _buildAccountSection(),
        ],
      ),
    );
  }

  Widget _buildNotificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionHeader(title: '通知設定'),
        SettingsSwitchTile(
          title: '賞味期限通知',
          subtitle: '期限間近の商品の通知を受け取ります',
          icon: Icons.notifications_outlined,
          value: _expiryNotificationsEnabled,
          onChanged: (value) async {
            setState(() {
              _expiryNotificationsEnabled = value;
            });
            await _notificationSettingsService
                .setExpiryNotificationsEnabled(value);
          },
        ),
        SettingsSwitchTile(
          title: '備蓄品通知',
          subtitle: '備蓄品の在庫不足時に通知を受け取ります',
          icon: Icons.inventory_2_outlined,
          value: _stockNotificationsEnabled,
          onChanged: (value) async {
            setState(() {
              _stockNotificationsEnabled = value;
            });
            await _notificationSettingsService
                .setStockNotificationsEnabled(value);
          },
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionHeader(title: 'カテゴリ管理'),
        SettingsListTile(
          title: 'カテゴリ管理',
          subtitle: '商品カテゴリの追加、修正、削除',
          icon: Icons.category_outlined,
          onTap: () {
            context.push('/category-management');
          },
        ),
      ],
    );
  }

  Widget _buildFamilySharingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionHeader(title: '家族共有'),
        SettingsListTile(
          title: '共有設定',
          subtitle: '家族と冷蔵庫を共有・メンバー管理',
          icon: Icons.people_outline,
          onTap: () {
            context.push('/household');
          },
        ),
      ],
    );
  }

  Widget _buildDataManagementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionHeader(title: 'データ管理'),
        SettingsListTile(
          title: 'キャッシュ削除',
          subtitle: 'アプリのキャッシュデータを削除します',
          icon: Icons.delete_outline,
          onTap: () {
            SettingsDialogs.showCacheDeleteDialog(context);
          },
        ),
        SettingsListTile(
          title: 'データバックアップ',
          subtitle:
              _isBackingUp ? 'バックアップ中...' : 'データをクラウドにバックアップします',
          icon: Icons.cloud_upload_outlined,
          onTap: _isBackingUp
              ? () {}
              : () {
                  SettingsDialogs.showBackupDialog(
                    context,
                    _backupService,
                    () {
                      if (mounted) setState(() => _isBackingUp = true);
                    },
                    () {
                      if (mounted) setState(() => _isBackingUp = false);
                    },
                  );
                },
        ),
        SettingsListTile(
          title: 'データ復元',
          subtitle: _isRestoring ? '復元中...' : 'バックアップしたデータを復元します',
          icon: Icons.cloud_download_outlined,
          onTap: _isRestoring
              ? () {}
              : () {
                  SettingsDialogs.showRestoreDialog(
                    context,
                    _backupService,
                    () {
                      if (mounted) setState(() => _isRestoring = true);
                    },
                    () {
                      if (mounted) setState(() => _isRestoring = false);
                    },
                  );
                },
        ),
      ],
    );
  }

  Widget _buildAppInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionHeader(title: 'アプリ情報'),
        SettingsListTile(
          title: 'バージョン情報',
          subtitle: '現在のバージョン: ${AppStrings.appVersion}',
          icon: Icons.info_outline,
          onTap: () {
            SettingsDialogs.showVersionInfoDialog(context);
          },
        ),
        SettingsListTile(
          title: '利用規約',
          subtitle: 'サービス利用規約を確認します',
          icon: Icons.description_outlined,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('利用規約ページは準備中です。')),
            );
          },
        ),
        SettingsListTile(
          title: 'プライバシーポリシー',
          subtitle: 'プライバシーポリシーを確認します',
          icon: Icons.privacy_tip_outlined,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('プライバシーポリシーページは準備中です。')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionHeader(title: 'アカウント'),
        SettingsListTile(
          title: 'ログアウト',
          subtitle: 'アカウントからログアウトします',
          icon: Icons.logout,
          onTap: () {
            SettingsDialogs.showLogoutDialog(context, ref);
          },
        ),
        SettingsListTile(
          title: 'アカウント削除',
          subtitle: 'アカウントとすべてのデータを完全に削除します',
          icon: Icons.person_remove,
          onTap: () {
            SettingsDialogs.showDeleteAccountDialog(context, ref);
          },
        ),
      ],
    );
  }
}
