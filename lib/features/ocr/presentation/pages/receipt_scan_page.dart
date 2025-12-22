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

enum StorageType { fridge, stock }

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

  Future<void> _pickImage() async {
    try {
      bool hasPermission = await PermissionService.checkCameraPermission();
      if (!hasPermission) {
        final needsSettings =
            await PermissionService.shouldOpenSettingsForCamera();

        if (needsSettings) {
          if (mounted) {
            _showCameraPermissionDialog();
          }
          return;
        }

        hasPermission = await PermissionService.requestCameraPermission();
        if (!hasPermission) {
          if (mounted) {
            _showCameraPermissionDialog();
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('画像選択失敗: $e')));
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
            if (mounted) {
              _showPhotoLibraryPermissionDialog();
            }
            return;
          }

          hasPermission =
              await PermissionService.requestPhotoLibraryPermission();
          if (!hasPermission) {
            if (mounted) {
              _showPhotoLibraryPermissionDialog();
            }
            return;
          }
        }
      }

      // 최대 5개까지 선택 가능
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 90,
      );

      if (images.isNotEmpty) {
        // 최대 5개로 제한
        final selectedImages = images.take(5).toList();

        if (images.length > 5) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('最大5枚まで選択できます。最初の5枚を選択しました。'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }

        setState(() {
          _selectedImagePaths = selectedImages.map((img) => img.path).toList();
          _savedItems.clear();
          _scannedItems = [];
          _errorMessage = null;
          _imageLoadingStates.clear();
        });

        // 모든 이미지에 대해 OCR 처리
        _loadAllOCRResults(_selectedImagePaths);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('画像選択失敗: $e')));
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
        setState(() {
          _isLoading = false;
        });
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

  void _removeItem(int index) {
    final removedItem = _scannedItems[index];
    setState(() {
      _scannedItems.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${removedItem.name}を削除しました'),
        action: SnackBarAction(
          label: '元に戻す',
          onPressed: () {
            setState(() {
              _scannedItems.insert(index, removedItem);
            });
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

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

      setState(() {
        _savedItems[item.id] = type;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${item.name}を${type == StorageType.fridge ? '冷蔵庫' : '備蓄品'}に追加しました',
            ),
            duration: const Duration(seconds: 1),
          ),
        );

        // 모든 아이템이 저장되었는지 확인
        final allItemsSaved = _scannedItems.every(
          (scannedItem) => _savedItems.containsKey(scannedItem.id),
        );

        if (allItemsSaved && _scannedItems.isNotEmpty) {
          // 모든 아이템이 저장되었으면 완료 모달 표시
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              _showCompletionModal(context);
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('保存失敗: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: const Text('レシートスキャン'),
      body: Column(
        children: [
          // 이미지 선택 버튼
          Padding(
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
          ),

          // 선택된 이미지 표시
          if (_selectedImagePaths.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              height: _selectedImagePaths.length > 1 ? 120 : 150,
              child: _selectedImagePaths.length > 1
                  ? ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImagePaths.length,
                      itemBuilder: (context, index) {
                        final imagePath = _selectedImagePaths[index];
                        final isLoading =
                            _imageLoadingStates[imagePath] ?? false;
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
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedImagePaths.removeAt(index);
                                        _imageLoadingStates.remove(imagePath);
                                        // 해당 이미지의 아이템들도 제거
                                        _scannedItems.removeWhere(
                                          (item) => item.id.contains(imagePath),
                                        );
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                // 이미지 번호 표시
                                Positioned(
                                  bottom: 4,
                                  left: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
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
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : GestureDetector(
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
                    ),
            ),
            if (_selectedImagePaths.length > 1) ...[
              Padding(
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
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Expanded(child: _buildOCRResults()),
          ] else
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 80,
                      color: Colors.grey.shade300,
                    ),
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
            ),
        ],
      ),
    );
  }

  Widget _buildOCRResults() {
    if (_isLoading) {
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

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: AppSpacing.md),
            Text(
              'OCR処理中にエラーが発生しました',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                _errorMessage!,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: () {
                if (_selectedImagePaths.isNotEmpty) {
                  if (_selectedImagePaths.length == 1) {
                    _loadOCRResults(_selectedImagePaths.first);
                  } else {
                    _loadAllOCRResults(_selectedImagePaths);
                  }
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('再試行'),
            ),
          ],
        ),
      );
    }

    if (_scannedItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: AppSpacing.md),
            Text(
              '認識された商品がありません',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '別の画像を試してみてください',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              Text(
                '${_scannedItems.length}個の商品を認識しました',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                '← スワイプで削除',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: _scannedItems.length,
            itemBuilder: (context, index) {
              final item = _scannedItems[index];
              final savedType = _savedItems[item.id];
              final isSaved = savedType != null;

              return Dismissible(
                key: Key(item.id),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  _removeItem(index);
                },
                background: Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Colors.red.shade400,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                child: InkWell(
                  onTap: () => _showEditBottomSheet(context, item, index),
                  borderRadius: BorderRadius.circular(12),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            '数量: ${item.quantity}',
                                            style: TextStyle(
                                              color: Colors.blue.shade700,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            '${item.price.toStringAsFixed(0)}円',
                                            style: TextStyle(
                                              color: Colors.green.shade700,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.edit_outlined,
                                size: 20,
                                color: Colors.grey.shade400,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          if (isSaved)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.green.shade200,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green.shade600,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${savedType == StorageType.fridge ? '冷蔵庫' : '備蓄品'}に追加済み',
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () =>
                                        _saveItem(item, StorageType.fridge),
                                    icon: const Icon(Icons.kitchen, size: 18),
                                    label: const Text('冷蔵庫'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.blue.shade700,
                                      side: BorderSide(
                                        color: Colors.blue.shade300,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () =>
                                        _saveItem(item, StorageType.stock),
                                    icon: const Icon(
                                      Icons.inventory_2,
                                      size: 18,
                                    ),
                                    label: const Text('備蓄品'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.orange.shade700,
                                      side: BorderSide(
                                        color: Colors.orange.shade300,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showImageViewer(BuildContext context, int initialIndex) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(230),
      builder: (dialogContext) => _ReceiptImageViewer(
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
              // 추가 등록: 데이터 클리어
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
              // 홈으로 이동
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

  void _showEditBottomSheet(BuildContext context, ReceiptItem item, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditReceiptItemBottomSheet(
        item: item,
        onSave: (updatedItem) {
          setState(() {
            _scannedItems[index] = updatedItem;
            // 저장된 아이템의 ID가 변경되었을 수 있으므로 _savedItems도 업데이트
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

class _EditReceiptItemBottomSheet extends StatefulWidget {
  final ReceiptItem item;
  final void Function(ReceiptItem) onSave;

  const _EditReceiptItemBottomSheet({required this.item, required this.onSave});

  @override
  State<_EditReceiptItemBottomSheet> createState() =>
      _EditReceiptItemBottomSheetState();
}

class _EditReceiptItemBottomSheetState
    extends State<_EditReceiptItemBottomSheet> {
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
            // ヘッダー
            Padding(
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
                    // 数量
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
                    // 価格
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
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
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
            ),
            // 保存ボタン
            Padding(
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
            ),
          ],
        ),
      ),
    );
  }
}

/// 영수증 이미지 뷰어 (전체 화면)
class _ReceiptImageViewer extends StatefulWidget {
  final List<String> imagePaths;
  final int initialIndex;

  const _ReceiptImageViewer({required this.imagePaths, this.initialIndex = 0});

  @override
  State<_ReceiptImageViewer> createState() => _ReceiptImageViewerState();
}

class _ReceiptImageViewerState extends State<_ReceiptImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          // 배경 (검은색 반투명)
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(color: Colors.black.withAlpha(230)),
          ),
          // 이미지 뷰어
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 헤더 (닫기 버튼, 현재 인덱스)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(191),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_currentIndex + 1} / ${widget.imagePaths.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                // 이미지 페이지뷰
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: widget.imagePaths.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: InteractiveViewer(
                          minScale: 0.5,
                          maxScale: 3.0,
                          child: Image.file(
                            File(widget.imagePaths[index]),
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // 네비게이션 인디케이터
                if (widget.imagePaths.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.imagePaths.length,
                        (index) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentIndex == index
                                ? Colors.white
                                : Colors.white.withAlpha(127),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
