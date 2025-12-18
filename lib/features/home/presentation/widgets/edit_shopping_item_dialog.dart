import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/design/spacing.dart';
import '../../../../core/design/color_schemes.dart';
import '../../domain/entities/shopping_list_item.dart';

class EditShoppingItemDialog extends StatefulWidget {
  final ShoppingListItem item;

  const EditShoppingItemDialog({
    super.key,
    required this.item,
  });

  @override
  State<EditShoppingItemDialog> createState() => _EditShoppingItemDialogState();
}

class _EditShoppingItemDialogState extends State<EditShoppingItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    // name에서 상품명과 수량 파싱
    final parsed = _parseNameAndQuantity(widget.item.name);
    _nameController = TextEditingController(text: parsed['name'] ?? '');
    _quantityController = TextEditingController(text: parsed['quantity'] ?? '1');
    _priceController = TextEditingController(
      text: widget.item.estimatedPrice?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  /// name에서 상품명과 수량 파싱
  /// 예: "商品名 (数量: 3)" -> {name: "商品名", quantity: "3"}
  /// 예: "商品名" -> {name: "商品名", quantity: "1"}
  Map<String, String> _parseNameAndQuantity(String name) {
    final quantityPattern = RegExp(r'\(数量:\s*(\d+)\)');
    final match = quantityPattern.firstMatch(name);
    
    if (match != null) {
      final quantity = match.group(1) ?? '1';
      final itemName = name.substring(0, match.start).trim();
      return {'name': itemName, 'quantity': quantity};
    } else {
      return {'name': name, 'quantity': '1'};
    }
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final quantityText = _quantityController.text.trim();
      final quantity = int.tryParse(quantityText) ?? 1;
      final priceText = _priceController.text.trim();
      final price = priceText.isEmpty ? null : int.tryParse(priceText);

      // 수량이 1보다 크면 name에 수량 포함
      final finalName = quantity > 1
          ? '$name (数量: $quantity)'
          : name;

      final updatedItem = widget.item.copyWith(
        name: finalName,
        estimatedPrice: price,
      );

      Navigator.of(context).pop(updatedItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '項目編集',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '商品名',
                  hintText: '商品名を入力',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '商品名を入力してください';
                  }
                  return null;
                },
                autofocus: true,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: '数量',
                  hintText: '例: 1',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '数量を入力してください';
                  }
                  final quantity = int.tryParse(value);
                  if (quantity == null || quantity <= 0) {
                    return '有効な数量を入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: '予想価格（オプション）',
                  hintText: '例: 250',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixText: '¥',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final price = int.tryParse(value);
                    if (price == null || price < 0) {
                      return '有効な価格を入力してください';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('キャンセル'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ElevatedButton(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorSchemes.light.primary,
                      foregroundColor: AppColorSchemes.light.onPrimary,
                    ),
                    child: const Text('保存'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

