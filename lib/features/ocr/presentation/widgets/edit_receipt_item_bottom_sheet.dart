import 'package:flutter/material.dart';

import '../../../../core/design/spacing.dart';
import '../../domain/entities/receipt_item.dart';

class EditReceiptItemBottomSheet extends StatefulWidget {
  final ReceiptItem item;
  final void Function(ReceiptItem) onSave;

  const EditReceiptItemBottomSheet({
    super.key,
    required this.item,
    required this.onSave,
  });

  @override
  State<EditReceiptItemBottomSheet> createState() =>
      _EditReceiptItemBottomSheetState();
}

class _EditReceiptItemBottomSheetState
    extends State<EditReceiptItemBottomSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _priceController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _quantityController = TextEditingController(
      text: widget.item.quantity.toString(),
    );
    _priceController = TextEditingController(
      text: widget.item.price.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final updatedItem = ReceiptItem(
        id: widget.item.id,
        name: _nameController.text.trim(),
        quantity: int.parse(_quantityController.text),
        price: double.parse(_priceController.text),
        purchaseDate: widget.item.purchaseDate,
      );
      widget.onSave(updatedItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const Divider(height: 1),
            _buildFormFields(),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          const Text(
            '商品情報を編集',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Flexible(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '商品名 *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.shopping_bag_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '商品名を入力してください。';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: '数量 *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
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
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: '価格 (円) *',
                border: OutlineInputBorder(),
                prefixIcon: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    '¥',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '価格を入力してください。';
                }
                final price = double.tryParse(value);
                if (price == null || price <= 0) {
                  return '正しい価格を入力してください。';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: ElevatedButton(
        onPressed: _handleSave,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          '保存',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
