import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/spacing.dart';
import '../../domain/entities/fridge_item.dart';
import '../providers/fridge_provider.dart';
import '../../../settings/presentation/providers/category_provider.dart';

class EditFridgeItemBottomSheet extends ConsumerStatefulWidget {
  final FridgeItem item;

  const EditFridgeItemBottomSheet({super.key, required this.item});

  @override
  ConsumerState<EditFridgeItemBottomSheet> createState() =>
      _EditFridgeItemBottomSheetState();
}

class _EditFridgeItemBottomSheetState
    extends ConsumerState<EditFridgeItemBottomSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _targetQuantityController;
  String? _selectedCategory;
  DateTime? _expiryDate;
  bool _isFrozen = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _quantityController = TextEditingController(
      text: widget.item.quantity.toString(),
    );
    _targetQuantityController = TextEditingController(
      text: widget.item.targetQuantity?.toString() ?? '',
    );
    _selectedCategory = widget.item.category;
    _expiryDate = widget.item.expiryDate;
    _isFrozen = widget.item.isFrozen;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _targetQuantityController.dispose();
    super.dispose();
  }

  Future<void> _selectExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      locale: const Locale('ja', 'JP'),
    );
    if (picked != null && picked != _expiryDate) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;
    if (_expiryDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('賞味期限を選択してください。')));
      return;
    }

    final updatedItem = FridgeItem(
      id: widget.item.id,
      name: _nameController.text.trim(),
      quantity: int.parse(_quantityController.text),
      category: _selectedCategory,
      expiryDate: _expiryDate!,
      createdAt: widget.item.createdAt,
      updatedAt: DateTime.now(),
      isFrozen: _isFrozen,
      targetQuantity: _targetQuantityController.text.isNotEmpty
          ? int.tryParse(_targetQuantityController.text)
          : null,
    );

    try {
      await ref.read(fridgeRepositoryProvider).updateFridgeItem(updatedItem);
      if (mounted) {
        Navigator.of(context).pop();
        ref.invalidate(fridgeItemsProvider); // Invalidate to trigger refresh and reschedule notifications
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('冷蔵庫アイテムを修正しました。')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('修正失敗: $e')));
      }
    }
  }

  Future<void> _deleteItem() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除確認'),
        content: Text('${widget.item.name}を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref
            .read(fridgeRepositoryProvider)
            .deleteFridgeItem(widget.item.id);
        if (mounted) {
          Navigator.of(context).pop();
          ref.invalidate(fridgeItemsProvider);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('冷蔵庫アイテムを削除しました。')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('削除失敗: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ヘッダー
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  const Text(
                    '冷蔵庫アイテム修正',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // フォームフィールド
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 商品名
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: '商品名 *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '商品名を入力してください。';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // 数量
                    TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: '数量 *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '数量を入力してください。';
                        }
                        final quantity = int.tryParse(value);
                        if (quantity == null || quantity <= 0) {
                          return '正しい数量を入力してください。';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // 目標数量 (목표 수량)
                    TextFormField(
                      controller: _targetQuantityController,
                      decoration: const InputDecoration(
                        labelText: '目標数量（任意）',
                        hintText: '在庫がこの数量を下回ると通知が送信されます',
                        border: OutlineInputBorder(),
                        helperText: '空欄の場合はデフォルト値(5)が使用されます',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final targetQuantity = int.tryParse(value);
                          if (targetQuantity == null || targetQuantity <= 0) {
                            return '正しい数量を入力してください。';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // 카테고리
                    _buildCategoryDropdown(),
                    const SizedBox(height: AppSpacing.md),
                    // 賞味期限
                    OutlinedButton(
                      onPressed: _selectExpiryDate,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(AppSpacing.md),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            _expiryDate == null
                                ? '賞味期限選択 *'
                                : '賞味期限: ${_expiryDate!.year}/${_expiryDate!.month}/${_expiryDate!.day}',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // 冷凍保存
                    CheckboxListTile(
                      title: const Text('冷凍保存'),
                      value: _isFrozen,
                      onChanged: (value) {
                        setState(() {
                          _isFrozen = value ?? false;
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // 삭제 버튼
                    OutlinedButton.icon(
                      onPressed: _deleteItem,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                      ),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('削除'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // 저장 버튼
                    ElevatedButton(
                      onPressed: _saveItem,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                      ),
                      child: const Text('保存'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      data: (categories) {
        // 현재 선택된 카테고리가 목록에 있는지 확인
        final categoryNames = categories.map((c) => c.name).toList();
        final validCategory = categoryNames.contains(_selectedCategory)
            ? _selectedCategory
            : null;

        return DropdownButtonFormField<String>(
          value: validCategory,
          decoration: const InputDecoration(
            labelText: 'カテゴリ',
            border: OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('選択しない'),
            ),
            ...categories.map(
              (category) => DropdownMenuItem<String>(
                value: category.name,
                child: Text(category.name),
              ),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
          },
        );
      },
      loading: () => const InputDecorator(
        decoration: InputDecoration(
          labelText: 'カテゴリ',
          border: OutlineInputBorder(),
        ),
        child: SizedBox(
          height: 24,
          child: Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ),
      error: (error, stack) => DropdownButtonFormField<String>(
        value: null,
        decoration: const InputDecoration(
          labelText: 'カテゴリ',
          border: OutlineInputBorder(),
        ),
        items: const [
          DropdownMenuItem<String>(
            value: null,
            child: Text('読み込み失敗'),
          ),
        ],
        onChanged: null,
      ),
    );
  }
}
