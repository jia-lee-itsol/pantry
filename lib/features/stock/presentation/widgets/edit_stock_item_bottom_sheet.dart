import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/spacing.dart';
import '../../domain/entities/stock_item.dart';
import '../providers/stock_provider.dart';

class EditStockItemBottomSheet extends ConsumerStatefulWidget {
  final StockItem item;

  const EditStockItemBottomSheet({super.key, required this.item});

  @override
  ConsumerState<EditStockItemBottomSheet> createState() =>
      _EditStockItemBottomSheetState();
}

class _EditStockItemBottomSheetState
    extends ConsumerState<EditStockItemBottomSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _targetQuantityController;
  late final TextEditingController _categoryController;
  DateTime? _expiryDate;
  final _formKey = GlobalKey<FormState>();

  // 카테고리 리스트
  static const List<String> _categories = [
    '飲料水/飲み物',
    '主食類',
    '缶詰/加工食品',
    '乳製品',
    'その他',
  ];

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
    _categoryController = TextEditingController(
      text: widget.item.category ?? '',
    );
    _expiryDate = widget.item.expiryDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _targetQuantityController.dispose();
    _categoryController.dispose();
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

    final updatedItem = widget.item.copyWith(
      name: _nameController.text.trim(),
      quantity: int.parse(_quantityController.text),
      targetQuantity: _targetQuantityController.text.isNotEmpty
          ? int.tryParse(_targetQuantityController.text)
          : null,
      category: _categoryController.text.trim().isEmpty
          ? null
          : _categoryController.text.trim(),
      expiryDate: _expiryDate,
      lastUpdated: DateTime.now(),
    );

    try {
      await ref.read(stockRepositoryProvider).updateStockItem(updatedItem);
      if (mounted) {
        Navigator.of(context).pop();
        ref.invalidate(stockItemsProvider);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('備蓄品を修正しました。')));
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
        await ref.read(stockRepositoryProvider).deleteStockItem(widget.item.id);
        if (mounted) {
          Navigator.of(context).pop();
          ref.invalidate(stockItemsProvider);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('備蓄品を削除しました。')));
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
                    '備蓄品修正',
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
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _categoryController,
                            decoration: const InputDecoration(
                              labelText: 'カテゴリ',
                              border: OutlineInputBorder(),
                              hintText: 'カテゴリを入力してください',
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.arrow_drop_down),
                          onSelected: (value) {
                            setState(() {
                              _categoryController.text = value;
                            });
                          },
                          itemBuilder: (context) => _categories
                              .map(
                                (category) => PopupMenuItem(
                                  value: category,
                                  child: Text(category),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
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
                                ? '賞味期限選択（任意）'
                                : '賞味期限: ${_expiryDate!.year}/${_expiryDate!.month}/${_expiryDate!.day}',
                          ),
                          if (_expiryDate != null) ...[
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                setState(() {
                                  _expiryDate = null;
                                });
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ],
                      ),
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
}
