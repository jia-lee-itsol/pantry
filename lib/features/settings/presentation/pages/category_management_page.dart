import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/widgets/app_scaffold.dart';
import '../../../../core/design/spacing.dart';
import '../../domain/entities/category.dart';
import '../providers/category_provider.dart';

class CategoryManagementPage extends ConsumerStatefulWidget {
  const CategoryManagementPage({super.key});

  @override
  ConsumerState<CategoryManagementPage> createState() =>
      _CategoryManagementPageState();
}

class _CategoryManagementPageState
    extends ConsumerState<CategoryManagementPage> {
  final Map<String, IconData> _iconMap = {
    'apple': Icons.apple,
    'egg': Icons.egg,
    'local_drink': Icons.local_drink,
    'eco': Icons.eco,
    'ac_unit': Icons.ac_unit,
    'water_drop': Icons.water_drop,
    'rice_bowl': Icons.rice_bowl,
    'inventory_2': Icons.inventory_2,
    'category': Icons.category,
    'fastfood': Icons.fastfood,
    'bakery_dining': Icons.bakery_dining,
    'lunch_dining': Icons.lunch_dining,
    'local_pizza': Icons.local_pizza,
    'icecream': Icons.icecream,
    'restaurant': Icons.restaurant,
  };

  IconData _getIconFromName(String iconName) {
    return _iconMap[iconName] ?? Icons.category;
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return AppScaffold(
      title: const Text('カテゴリ管理'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        child: const Icon(Icons.add),
      ),
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(child: Text('カテゴリがありません。'));
          }

          return ReorderableListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: categories.length,
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              final reordered = List<Category>.from(categories);
              final item = reordered.removeAt(oldIndex);
              reordered.insert(newIndex, item);
              // 順序更新
              final updated = reordered.asMap().entries.map((e) {
                return e.value.copyWith(order: e.key + 1);
              }).toList();
              ref
                  .read(categoryRepositoryProvider)
                  .reorderCategories(updated)
                  .then((_) {
                    ref.invalidate(categoriesProvider);
                  });
            },
            itemBuilder: (context, index) {
              final category = categories[index];
              return Card(
                key: Key(category.id),
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ListTile(
                  leading: Icon(_getIconFromName(category.iconName)),
                  title: Text(category.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () =>
                            _showEditCategoryDialog(context, category),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.red,
                        onPressed: () =>
                            _showDeleteCategoryDialog(context, category),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('エラー: $error')),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    IconData selectedIcon = Icons.category;
    String selectedIconName = 'category';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('カテゴリ追加'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'カテゴリ名',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: AppSpacing.md),
                const Text('アイコン選択'),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: _iconMap.entries.map((entry) {
                    final isSelected = entry.value == selectedIcon;
                    return InkWell(
                      onTap: () {
                        setDialogState(() {
                          selectedIcon = entry.value;
                          selectedIconName = entry.key;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          entry.value,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade700,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('カテゴリ名を入力してください。')),
                  );
                  return;
                }

                final newCategory = Category(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text.trim(),
                  iconName: selectedIconName,
                  order: 999,
                  createdAt: DateTime.now(),
                );

                ref
                    .read(categoryRepositoryProvider)
                    .addCategory(newCategory)
                    .then((_) {
                      ref.invalidate(categoriesProvider);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('カテゴリを追加しました。')),
                        );
                      }
                    })
                    .catchError((error) {
                      if (context.mounted) {
                        String errorMessage = '追加失敗';
                        if (error.toString().contains(
                          'MissingPluginException',
                        )) {
                          errorMessage = '保存機能を使用できません。アプリを再起動するか再ビルドしてください。';
                        } else {
                          errorMessage = '追加失敗: $error';
                        }
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(errorMessage)));
                      }
                    });
              },
              child: const Text('追加'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, Category category) {
    final nameController = TextEditingController(text: category.name);
    IconData selectedIcon = _getIconFromName(category.iconName);
    String selectedIconName = category.iconName;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('カテゴリ修正'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'カテゴリ名',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: AppSpacing.md),
                const Text('アイコン選択'),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: _iconMap.entries.map((entry) {
                    final isSelected = entry.value == selectedIcon;
                    return InkWell(
                      onTap: () {
                        setDialogState(() {
                          selectedIcon = entry.value;
                          selectedIconName = entry.key;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          entry.value,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade700,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('カテゴリ名を入力してください。')),
                  );
                  return;
                }

                final updatedCategory = category.copyWith(
                  name: nameController.text.trim(),
                  iconName: selectedIconName,
                );

                ref
                    .read(categoryRepositoryProvider)
                    .updateCategory(updatedCategory)
                    .then((_) {
                      ref.invalidate(categoriesProvider);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('カテゴリを修正しました。')),
                        );
                      }
                    })
                    .catchError((error) {
                      if (context.mounted) {
                        String errorMessage = '修正失敗';
                        if (error.toString().contains(
                          'MissingPluginException',
                        )) {
                          errorMessage = '保存機能を使用できません。アプリを再起動するか再ビルドしてください。';
                        } else {
                          errorMessage = '修正失敗: $error';
                        }
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(errorMessage)));
                      }
                    });
              },
              child: const Text('修正'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteCategoryDialog(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('カテゴリ削除'),
        content: Text('${category.name}カテゴリを削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(categoryRepositoryProvider)
                  .deleteCategory(category.id)
                  .then((_) {
                    ref.invalidate(categoriesProvider);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${category.name}カテゴリを削除しました。')),
                      );
                    }
                  })
                  .catchError((error) {
                    if (context.mounted) {
                      String errorMessage = '削除失敗';
                      if (error.toString().contains('MissingPluginException')) {
                        errorMessage = '保存機能を使用できません。アプリを再起動するか再ビルドしてください。';
                      } else {
                        errorMessage = '削除失敗: $error';
                      }
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(errorMessage)));
                    }
                  });
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }
}
