import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/design/widgets/app_scaffold.dart';
import '../../../../core/design/spacing.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/services/expiry_date_service.dart';
import '../../../ocr/presentation/providers/ocr_provider.dart';
import '../../../ocr/domain/entities/receipt_item.dart';
import '../../../barcode/presentation/providers/barcode_provider.dart';
import '../../../settings/presentation/providers/category_provider.dart';
import '../providers/fridge_provider.dart';
import '../../domain/entities/fridge_item.dart';

class AddFridgeItemPage extends ConsumerStatefulWidget {
  const AddFridgeItemPage({super.key});

  @override
  ConsumerState<AddFridgeItemPage> createState() => _AddFridgeItemPageState();
}

class _AddFridgeItemPageState extends ConsumerState<AddFridgeItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _targetQuantityController = TextEditingController();
  String? _selectedCategory;
  DateTime? _expiryDate;
  bool _autoRegisterExpiry = false;
  final ImagePicker _imagePicker = ImagePicker();
  String? _selectedImagePath;
  String? _barcodeImagePath;

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _targetQuantityController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      // 카메라 권한 확인 및 요청
      bool hasPermission = await PermissionService.checkCameraPermission();
      if (!hasPermission) {
        hasPermission = await PermissionService.requestCameraPermission();
        if (!hasPermission) {
          if (mounted) {
            if (await PermissionService.isCameraPermanentlyDenied()) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('カメラ権限が必要'),
                  content: const Text(
                    'レシートをスキャンするためにカメラ権限が必要です。\n設定でカメラ権限を許可してください。',
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
            } else {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('カメラ権限が必要です。')));
            }
          }
          return;
        }
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );

      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('画像選択失敗: $e')));
      }
    }
  }

  Future<void> _pickImageForBarcode() async {
    try {
      // 카메라 권한 확인 및 요청
      bool hasPermission = await PermissionService.checkCameraPermission();
      if (!hasPermission) {
        hasPermission = await PermissionService.requestCameraPermission();
        if (!hasPermission) {
          if (mounted) {
            if (await PermissionService.isCameraPermanentlyDenied()) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('カメラ権限が必要です'),
                  content: const Text('設定からカメラ権限を有効にしてください。'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('カメラ権限が必要です')),
              );
            }
          }
          return;
        }
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );

      if (image != null) {
        setState(() {
          _barcodeImagePath = image.path;
          _selectedImagePath = null; // OCR 이미지 초기화
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('画像選択失敗: $e')),
        );
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      // フォトライブラリ権限の確認 (iOS)
      if (Platform.isIOS) {
        bool hasPermission =
            await PermissionService.requestPhotoLibraryPermission();
        if (!hasPermission) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('フォトライブラリ権限が必要です。')));
          }
          return;
        }
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('画像選択失敗: $e')));
      }
    }
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
      // 가격은 냉장고 아이템에는 불필요하므로 무시
    });

    // 자동 등록이 체크되어 있으면 AI로 유통기한을 자동 설정
    if (_autoRegisterExpiry && receiptItem.name.isNotEmpty) {
      await _updateExpiryDateWithAI(receiptItem.name);
    }
  }

  void _onAutoRegisterChanged(bool? value) async {
    setState(() {
      _autoRegisterExpiry = value ?? false;
    });

    // 체크되면 AI로 상품명 기준 유통기한을 자동 설정
    if (_autoRegisterExpiry && _nameController.text.trim().isNotEmpty) {
      await _updateExpiryDateWithAI(_nameController.text.trim());
    } else if (!_autoRegisterExpiry) {
      // チェック解除時に賞味期限を初期化
      setState(() {
        _expiryDate = null;
      });
    }
  }

  void _onProductNameChanged(String value) async {
    // 자동 등록이 체크되어 있고 상품명이 입력되면 AI로 유통기한을 자동 설정
    if (_autoRegisterExpiry && value.trim().isNotEmpty) {
      await _updateExpiryDateWithAI(value.trim());
    }
  }

  Future<void> _updateExpiryDateWithAI(String productName) async {
    // ローディング表示のため状態更新
    setState(() {
      _expiryDate = null; // ローディング中を表示
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
      // AI失敗時はデフォルト値を使用
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('賞味期限を選択してください。')));
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
        ref.invalidate(fridgeItemsProvider); // Invalidate to trigger refresh and reschedule notifications
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('冷蔵庫アイテムを追加しました。')));
      }
    } catch (e) {
      debugPrint('[AddFridgeItemPage] 아이템 저장 실패: $e');
      debugPrint('[AddFridgeItemPage] 에러 타입: ${e.runtimeType}');
      
      if (mounted) {
        // 에러 메시지가 너무 길면 요약
        final errorMessage = e.toString().length > 150
            ? '保存に失敗しました。Firebase ConsoleでFirestoreのセキュリティルールを確認してください。'
            : '保存失敗: ${e.toString().replaceAll('Exception: ', '')}';
        
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
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
            // バーコードスキャンセクション
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'バーコードスキャン',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickImageForBarcode,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('バーコードスキャン'),
                          ),
                        ),
                      ],
                    ),
                    if (_barcodeImagePath != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_barcodeImagePath!),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildBarcodeScanResult(),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // OCRセクション
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.receipt,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'レシートで追加',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('カメラ'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickImageFromGallery,
                            icon: const Icon(Icons.photo_library),
                            label: const Text('ギャラリー'),
                          ),
                        ),
                      ],
                    ),
                    if (_selectedImagePath != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_selectedImagePath!),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildOCRResults(),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.md),
            // 手動入力セクション
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
                Expanded(child: _buildCategoryDropdown()),
              ],
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
            // 自動登録チェックボックス
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

  Widget _buildBarcodeScanResult() {
    if (_barcodeImagePath == null) {
      return const SizedBox.shrink();
    }

    final barcodeAsync = ref.watch(barcodeScanProvider(_barcodeImagePath!));

    return barcodeAsync.when(
      data: (result) {
        if (result == null) {
          return const Text(
            'バーコードが見つかりませんでした。',
            style: TextStyle(color: Colors.grey),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'バーコード: ${result.barcode}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            ElevatedButton.icon(
              onPressed: () {
                _nameController.text = result.barcode;
                _onProductNameChanged(result.barcode);
              },
              icon: const Icon(Icons.check),
              label: const Text('商品名に使用'),
            ),
          ],
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Text(
        'バーコードスキャン失敗: $error',
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _buildOCRResults() {
    if (_selectedImagePath == null) {
      return const SizedBox.shrink();
    }

    final ocrAsync = ref.watch(ocrScanProvider(_selectedImagePath!));

    return ocrAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return const Text(
            '認識された商品がありません。',
            style: TextStyle(color: Colors.grey),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('認識された商品:', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            ...items.map(
              (item) => Card(
                child: ListTile(
                  title: Text(item.name),
                  subtitle: Text('数量: ${item.quantity}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _applyOCRResult(item),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) =>
          Text('OCR処理失敗: $error', style: const TextStyle(color: Colors.red)),
    );
  }

  Widget _buildCategoryDropdown() {
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      data: (categories) {
        return DropdownButtonFormField<String>(
          initialValue: _selectedCategory,
          decoration: const InputDecoration(
            labelText: 'カテゴリ',
            border: OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem<String>(value: null, child: Text('選択しない')),
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
        initialValue: null,
        decoration: const InputDecoration(
          labelText: 'カテゴリ',
          border: OutlineInputBorder(),
        ),
        items: const [
          DropdownMenuItem<String>(value: null, child: Text('読み込み失敗')),
        ],
        onChanged: null,
      ),
    );
  }
}
