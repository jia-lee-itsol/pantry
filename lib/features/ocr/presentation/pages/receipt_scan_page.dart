import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/design/spacing.dart';
import '../../../../core/design/widgets/app_scaffold.dart';
import '../../../../core/services/permission_service.dart';
import '../../../fridge/domain/entities/fridge_item.dart';
import '../../../fridge/presentation/providers/fridge_provider.dart';
import '../../../stock/domain/entities/stock_item.dart';
import '../../../stock/presentation/providers/stock_provider.dart';
import '../../domain/entities/receipt_item.dart';
import '../providers/ocr_provider.dart';
import '../widgets/edit_receipt_item_bottom_sheet.dart';
import '../widgets/receipt_image_viewer.dart';
import '../widgets/receipt_item_card.dart';

class ReceiptScanPage extends ConsumerStatefulWidget {
  const ReceiptScanPage({super.key});

  @override
  ConsumerState<ReceiptScanPage> createState() => _ReceiptScanPageState();
}

class _ReceiptScanPageState extends ConsumerState<ReceiptScanPage> {
  final ImagePicker _imagePicker = ImagePicker();
  List<String> _selectedImagePaths = [];
  final Map<String, StorageType> _savedItems = {};
  List<ReceiptItem> _scannedItems = [];
  bool _isLoading = false;
  String? _errorMessage;
  final Map<String, bool> _imageLoadingStates = {};

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: const Text('レシートスキャン'),
      body: Column(
        children: [
          _buildImagePickerButtons(),
          if (_selectedImagePaths.isNotEmpty) ...[
            _buildSelectedImages(),
            if (_selectedImagePaths.length > 1) _buildImageCountInfo(),
            const SizedBox(height: AppSpacing.md),
            Expanded(child: _buildOCRResults()),
          ] else
            _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildImagePickerButtons() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text('カメラ'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _pickImageFromGallery,
              icon: const Icon(Icons.photo_library),
              label: const Text('ギャラリー'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedImages() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      height: _selectedImagePaths.length > 1 ? 120 : 150,
      child: _selectedImagePaths.length > 1
          ? _buildMultipleImages()
          : _buildSingleImage(),
    );
  }

  Widget _buildMultipleImages() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _selectedImagePaths.length,
      itemBuilder: (context, index) {
        final imagePath = _selectedImagePaths[index];
        final isLoading = _imageLoadingStates[imagePath] ?? false;
        return _buildImageThumbnail(imagePath, index, isLoading);
      },
    );
  }

  Widget _buildImageThumbnail(String imagePath, int index, bool isLoading) {
    return GestureDetector(
      onTap: () => _showImageViewer(context, index),
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: AppSpacing.sm),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(imagePath),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            if (isLoading)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(127),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            _buildRemoveButton(index, imagePath),
            _buildImageNumber(index),
          ],
        ),
      ),
    );
  }

  Widget _buildRemoveButton(int index, String imagePath) {
    return Positioned(
      top: 4,
      right: 4,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedImagePaths.removeAt(index);
            _imageLoadingStates.remove(imagePath);
            _scannedItems.removeWhere((item) => item.id.contains(imagePath));
          });
        },
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.close, color: Colors.white, size: 16),
        ),
      ),
    );
  }

  Widget _buildImageNumber(int index) {
    return Positioned(
      bottom: 4,
      left: 4,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(191),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '${index + 1}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSingleImage() {
    return GestureDetector(
      onTap: () => _showImageViewer(context, 0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(_selectedImagePaths.first),
            fit: BoxFit.contain,
            width: double.infinity,
          ),
        ),
      ),
    );
  }

  Widget _buildImageCountInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_selectedImagePaths.length}枚のレシートを選択中',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          TextButton.icon(
            onPressed: () => _showImageViewer(context, 0),
            icon: const Icon(Icons.fullscreen, size: 18),
            label: const Text('すべて確認'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: AppSpacing.md),
            Text(
              'レシートを撮影してください',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '商品名・数量・金額を自動認識します',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOCRResults() {
    if (_isLoading) return _buildLoadingState();
    if (_errorMessage != null) return _buildErrorState();
    if (_scannedItems.isEmpty) return _buildNoItemsState();
    return _buildItemsList();
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: AppSpacing.md),
          Text('レシートを解析中...'),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: AppSpacing.md),
          Text('OCR処理中にエラーが発生しました',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton.icon(
            onPressed: _retryOCR,
            icon: const Icon(Icons.refresh),
            label: const Text('再試行'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoItemsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: AppSpacing.md),
          Text(
            '認識された商品がありません',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '別の画像を試してみてください',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildItemsHeader(),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: _scannedItems.length,
            itemBuilder: (context, index) {
              final item = _scannedItems[index];
              return Dismissible(
                key: Key(item.id),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => _removeItem(index),
                background: _buildDismissBackground(),
                child: ReceiptItemCard(
                  item: item,
                  savedType: _savedItems[item.id],
                  onTap: () => _showEditBottomSheet(context, item, index),
                  onSaveToFridge: () => _saveItem(item, StorageType.fridge),
                  onSaveToStock: () => _saveItem(item, StorageType.stock),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildItemsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Text(
            '${_scannedItems.length}個の商品を認識しました',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            '← スワイプで削除',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.red.shade400,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(Icons.delete, color: Colors.white, size: 28),
    );
  }

  // === Actions ===

  Future<void> _pickImage() async {
    try {
      bool hasPermission = await PermissionService.checkCameraPermission();
      if (!hasPermission) {
        final needsSettings =
            await PermissionService.shouldOpenSettingsForCamera();
        if (needsSettings) {
          if (mounted) _showCameraPermissionDialog();
          return;
        }
        hasPermission = await PermissionService.requestCameraPermission();
        if (!hasPermission) {
          if (mounted) _showCameraPermissionDialog();
          return;
        }
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );

      if (image != null) {
        setState(() {
          _selectedImagePaths = [image.path];
          _savedItems.clear();
          _scannedItems = [];
          _errorMessage = null;
          _imageLoadingStates.clear();
        });
        _loadOCRResults(image.path);
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
      if (Platform.isIOS) {
        bool hasPermission =
            await PermissionService.checkPhotoLibraryPermission();
        if (!hasPermission) {
          final needsSettings =
              await PermissionService.shouldOpenSettingsForPhotoLibrary();
          if (needsSettings) {
            if (mounted) _showPhotoLibraryPermissionDialog();
            return;
          }
          hasPermission =
              await PermissionService.requestPhotoLibraryPermission();
          if (!hasPermission) {
            if (mounted) _showPhotoLibraryPermissionDialog();
            return;
          }
        }
      }

      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 90,
      );

      if (images.isNotEmpty) {
        final selectedImages = images.take(5).toList();

        if (images.length > 5 && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('最大5枚まで選択できます。最初の5枚を選択しました。'),
              duration: Duration(seconds: 2),
            ),
          );
        }

        setState(() {
          _selectedImagePaths = selectedImages.map((img) => img.path).toList();
          _savedItems.clear();
          _scannedItems = [];
          _errorMessage = null;
          _imageLoadingStates.clear();
        });

        _loadAllOCRResults(_selectedImagePaths);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('画像選択失敗: $e')),
        );
      }
    }
  }

  Future<void> _loadOCRResults(String imagePath) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _imageLoadingStates[imagePath] = true;
    });

    try {
      final items = await ref.read(ocrScanProvider(imagePath).future);
      if (mounted) {
        setState(() {
          _scannedItems = List.from(items);
          _isLoading = false;
          _imageLoadingStates[imagePath] = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
          _imageLoadingStates[imagePath] = false;
        });
      }
    }
  }

  Future<void> _loadAllOCRResults(List<String> imagePaths) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _scannedItems = [];
      for (final path in imagePaths) {
        _imageLoadingStates[path] = true;
      }
    });

    try {
      final allItems = <ReceiptItem>[];

      for (final imagePath in imagePaths) {
        try {
          final items = await ref.read(ocrScanProvider(imagePath).future);
          allItems.addAll(items);

          if (mounted) {
            setState(() {
              _imageLoadingStates[imagePath] = false;
              _scannedItems = List.from(allItems);
            });
          }
        } catch (e) {
          debugPrint('OCR処理失敗 for $imagePath: $e');
          if (mounted) {
            setState(() {
              _imageLoadingStates[imagePath] = false;
            });
          }
        }
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
          for (final path in imagePaths) {
            _imageLoadingStates[path] = false;
          }
        });
      }
    }
  }

  void _retryOCR() {
    if (_selectedImagePaths.isNotEmpty) {
      if (_selectedImagePaths.length == 1) {
        _loadOCRResults(_selectedImagePaths.first);
      } else {
        _loadAllOCRResults(_selectedImagePaths);
      }
    }
  }

  void _removeItem(int index) {
    final removedItem = _scannedItems[index];
    setState(() => _scannedItems.removeAt(index));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${removedItem.name}を削除しました'),
        action: SnackBarAction(
          label: '元に戻す',
          onPressed: () {
            setState(() => _scannedItems.insert(index, removedItem));
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _saveItem(ReceiptItem item, StorageType type) async {
    try {
      final now = DateTime.now();

      if (type == StorageType.fridge) {
        final fridgeRepository = ref.read(fridgeRepositoryProvider);
        final fridgeItem = FridgeItem(
          id: 'fridge_${now.millisecondsSinceEpoch}_${item.id}',
          name: item.name,
          quantity: item.quantity,
          expiryDate: now.add(const Duration(days: 7)),
          createdAt: now,
        );
        await fridgeRepository.addFridgeItem(fridgeItem);
        ref.invalidate(fridgeItemsProvider);
      } else {
        final stockRepository = ref.read(stockRepositoryProvider);
        final stockItem = StockItem(
          id: 'stock_${now.millisecondsSinceEpoch}_${item.id}',
          name: item.name,
          quantity: item.quantity,
          lastUpdated: now,
        );
        await stockRepository.addStockItem(stockItem);
        ref.invalidate(stockItemsProvider);
      }

      setState(() => _savedItems[item.id] = type);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${item.name}を${type == StorageType.fridge ? '冷蔵庫' : '備蓄品'}に追加しました',
            ),
            duration: const Duration(seconds: 1),
          ),
        );

        final allItemsSaved = _scannedItems.every(
          (scannedItem) => _savedItems.containsKey(scannedItem.id),
        );

        if (allItemsSaved && _scannedItems.isNotEmpty) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) _showCompletionModal(context);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失敗: $e')),
        );
      }
    }
  }

  // === Dialogs ===

  void _showCameraPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('カメラ権限が必要'),
        content: const Text('カメラ権限が必要です。\n設定でカメラ権限を許可してください。'),
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
        content: const Text('フォトライブラリ権限が必要です。\n設定で権限を許可してください。'),
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

  void _showImageViewer(BuildContext context, int initialIndex) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(230),
      builder: (dialogContext) => ReceiptImageViewer(
        imagePaths: _selectedImagePaths,
        initialIndex: initialIndex,
      ),
    );
  }

  void _showCompletionModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: AppSpacing.sm),
            Text('登録完了'),
          ],
        ),
        content: Text(
          'すべての商品（${_scannedItems.length}個）の登録が完了しました。',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              setState(() {
                _selectedImagePaths.clear();
                _scannedItems.clear();
                _savedItems.clear();
                _errorMessage = null;
                _imageLoadingStates.clear();
              });
            },
            child: const Text('追加登録'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.go('/');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('ホームに戻る'),
          ),
        ],
      ),
    );
  }

  void _showEditBottomSheet(
      BuildContext context, ReceiptItem item, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditReceiptItemBottomSheet(
        item: item,
        onSave: (updatedItem) {
          setState(() {
            _scannedItems[index] = updatedItem;
            final oldSavedType = _savedItems[item.id];
            if (oldSavedType != null) {
              _savedItems.remove(item.id);
              _savedItems[updatedItem.id] = oldSavedType;
            }
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
