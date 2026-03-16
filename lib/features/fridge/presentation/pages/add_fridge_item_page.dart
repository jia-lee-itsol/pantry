import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/design/widgets/app_scaffold.dart';
import '../../../../core/design/spacing.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/services/expiry_date_service.dart';
import '../../../ocr/domain/entities/receipt_item.dart';
import '../providers/fridge_provider.dart';
import '../../domain/entities/fridge_item.dart';
import '../widgets/barcode_scan_section.dart';
import '../widgets/ocr_receipt_section.dart';
import '../widgets/scanned_item_card.dart';
import '../widgets/category_dropdown.dart';

class AddFridgeItemPage extends ConsumerStatefulWidget {
  const AddFridgeItemPage({super.key});

  @override
  ConsumerState<AddFridgeItemPage> createState() => _AddFridgeItemPageState();
}

class _AddFridgeItemPageState extends ConsumerState<AddFridgeItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _priceController = TextEditingController();
  final _targetQuantityController = TextEditingController();
  String? _selectedCategory;
  DateTime? _expiryDate;
  bool _autoRegisterExpiry = false;
  final ImagePicker _imagePicker = ImagePicker();
  String? _selectedImagePath;
  String? _barcodeImagePath;
  List<ReceiptItem> _scannedItems = [];

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _targetQuantityController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final imagePath = await _pickImageFromSource(ImageSource.camera);
    if (imagePath != null) {
      setState(() {
        _selectedImagePath = imagePath;
      });
    }
  }

  Future<void> _pickImageForBarcode() async {
    final imagePath = await _pickImageFromSource(ImageSource.camera);
    if (imagePath != null) {
      setState(() {
        _barcodeImagePath = imagePath;
        _selectedImagePath = null;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final imagePath = await _pickImageFromSource(ImageSource.gallery);
    if (imagePath != null) {
      setState(() {
        _selectedImagePath = imagePath;
      });
    }
  }

  Future<String?> _pickImageFromSource(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        bool hasPermission = await PermissionService.checkCameraPermission();
        if (!hasPermission) {
          final needsSettings =
              await PermissionService.shouldOpenSettingsForCamera();

          if (needsSettings) {
            if (mounted) _showCameraPermissionDialog();
            return null;
          }

          hasPermission = await PermissionService.requestCameraPermission();
          if (!hasPermission) {
            if (mounted) _showCameraPermissionDialog();
            return null;
          }
        }
      } else if (source == ImageSource.gallery && Platform.isIOS) {
        bool hasPermission =
            await PermissionService.checkPhotoLibraryPermission();
        if (!hasPermission) {
          final needsSettings =
              await PermissionService.shouldOpenSettingsForPhotoLibrary();

          if (needsSettings) {
            if (mounted) _showPhotoLibraryPermissionDialog();
            return null;
          }

          hasPermission =
              await PermissionService.requestPhotoLibraryPermission();
          if (!hasPermission) {
            if (mounted) _showPhotoLibraryPermissionDialog();
            return null;
          }
        }
      }

      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 90,
      );

      return image?.path;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('画像選択失敗: $e')),
        );
      }
      return null;
    }
  }

  void _showCameraPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('カメラ権限が必要'),
        content: const Text(
          'カメラ権限が必要です。\n設定でカメラ権限を許可してください。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              PermissionService.openSettings();
            },
            child: const Text('設定を開く'),
          ),
        ],
      ),
    );
  }

  void _showPhotoLibraryPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('フォトライブラリ権限が必要'),
        content: const Text(
          'フォトライブラリ権限が必要です。\n設定で権限を許可してください。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              PermissionService.openSettings();
            },
            child: const Text('設定を開く'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectExpiryDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (pickedDate != null) {
      setState(() {
        _expiryDate = pickedDate;
      });
    }
  }

  void _applyOCRResult(ReceiptItem receiptItem) async {
    setState(() {
      _nameController.text = receiptItem.name;
      _quantityController.text = receiptItem.quantity.toString();
      _priceController.text = receiptItem.price.toStringAsFixed(0);
    });

    if (_autoRegisterExpiry && receiptItem.name.isNotEmpty) {
      await _updateExpiryDateWithAI(receiptItem.name);
    }
  }

  void _onAutoRegisterChanged(bool? value) async {
    setState(() {
      _autoRegisterExpiry = value ?? false;
    });

    if (_autoRegisterExpiry && _nameController.text.trim().isNotEmpty) {
      await _updateExpiryDateWithAI(_nameController.text.trim());
    } else if (!_autoRegisterExpiry) {
      setState(() {
        _expiryDate = null;
      });
    }
  }

  void _onProductNameChanged(String value) async {
    if (_autoRegisterExpiry && value.trim().isNotEmpty) {
      await _updateExpiryDateWithAI(value.trim());
    }
  }

  Future<void> _updateExpiryDateWithAI(String productName) async {
    setState(() {
      _expiryDate = null;
    });

    try {
      final expiryDate = await ExpiryDateService.getExpiryDateWithAI(
        productName,
      );
      if (mounted) {
        setState(() {
          _expiryDate = expiryDate;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _expiryDate = ExpiryDateService.getDefaultExpiryDate(productName);
        });
      }
    }
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;
    if (_expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('賞味期限を選択してください。')),
      );
      return;
    }

    final item = FridgeItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      quantity: int.parse(_quantityController.text),
      category: _selectedCategory,
      expiryDate: _expiryDate!,
      createdAt: DateTime.now(),
      targetQuantity: _targetQuantityController.text.isNotEmpty
          ? int.tryParse(_targetQuantityController.text)
          : null,
    );

    try {
      debugPrint('[AddFridgeItemPage] 아이템 저장 시작: ${item.name}');
      await ref.read(fridgeRepositoryProvider).addFridgeItem(item);
      debugPrint('[AddFridgeItemPage] 아이템 저장 성공');

      if (mounted) {
        Navigator.of(context).pop();
        ref.invalidate(fridgeItemsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('冷蔵庫アイテムを追加しました。')),
        );
      }
    } catch (e) {
      debugPrint('[AddFridgeItemPage] 아이템 저장 실패: $e');
      debugPrint('[AddFridgeItemPage] 에러 타입: ${e.runtimeType}');

      if (mounted) {
        final errorMessage = e.toString().length > 150
            ? '保存に失敗しました。Firebase ConsoleでFirestoreのセキュリティルールを確認してください。'
            : '保存失敗: ${e.toString().replaceAll('Exception: ', '')}';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: const Text('冷蔵庫アイテム追加'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            BarcodeScanSection(
              barcodeImagePath: _barcodeImagePath,
              onScanPressed: _pickImageForBarcode,
              onBarcodeApplied: (barcode) {
                _nameController.text = barcode;
                _onProductNameChanged(barcode);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            OcrReceiptSection(
              selectedImagePath: _selectedImagePath,
              onCameraPressed: _pickImage,
              onGalleryPressed: _pickImageFromGallery,
              onItemsScanned: (items) {
                setState(() {
                  _scannedItems = items;
                });
              },
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.md),
            _buildScannedItemsList(),
            _buildManualInputSection(),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: _saveItem,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannedItemsList() {
    if (_scannedItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'スキャンされた商品',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ..._scannedItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return ScannedItemCard(
            item: item,
            onApply: () => _applyOCRResult(item),
            onRemove: () {
              setState(() {
                _scannedItems.removeAt(index);
              });
            },
          );
        }),
        const SizedBox(height: AppSpacing.md),
        const Divider(),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }

  Widget _buildManualInputSection() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: '商品名 *',
            border: OutlineInputBorder(),
          ),
          onChanged: _onProductNameChanged,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '商品名を入力してください。';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: TextFormField(
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
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: '金額',
                  border: OutlineInputBorder(),
                  suffixText: '円',
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        CategoryDropdown(
          selectedCategory: _selectedCategory,
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
          },
        ),
        const SizedBox(height: AppSpacing.md),
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
        CheckboxListTile(
          title: const Text('自動登録'),
          subtitle: const Text('商品名に基づいて賞味期限を自動設定'),
          value: _autoRegisterExpiry,
          onChanged: _onAutoRegisterChanged,
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton(
          onPressed: _autoRegisterExpiry ? null : _selectExpiryDate,
          child: Row(
            children: [
              const Icon(Icons.calendar_today),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  _expiryDate == null
                      ? '賞味期限選択 *'
                      : '賞味期限: ${_expiryDate!.year}/${_expiryDate!.month}/${_expiryDate!.day}',
                ),
              ),
              if (_autoRegisterExpiry)
                Icon(
                  Icons.auto_awesome,
                  color: Theme.of(context).colorScheme.primary,
                  size: 18,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
