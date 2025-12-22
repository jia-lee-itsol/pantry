import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../fridge/domain/entities/fridge_item.dart';
import '../../../fridge/presentation/providers/fridge_provider.dart';
import '../../../stock/domain/entities/stock_item.dart';
import '../../../stock/presentation/providers/stock_provider.dart';
import '../../domain/entities/receipt_item.dart';
import '../providers/ocr_provider.dart';

enum StorageType { fridge, stock }

class OCRPage extends ConsumerStatefulWidget {
  const OCRPage({super.key});

  @override
  ConsumerState<OCRPage> createState() => _OCRPageState();
}

class _OCRPageState extends ConsumerState<OCRPage> {
  final ImagePicker _imagePicker = ImagePicker();
  String? _selectedImagePath;
  final Map<String, StorageType?> _itemSelections = {};
  final Set<String> _savedItems = {};

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );

      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
          _itemSelections.clear();
          _savedItems.clear();
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

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
          _itemSelections.clear();
          _savedItems.clear();
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
        _savedItems.add(item.id);
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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失敗: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('レシートOCR')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('カメラ'),
                ),
                ElevatedButton.icon(
                  onPressed: _pickImageFromGallery,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('ギャラリー'),
                ),
              ],
            ),
          ),
          if (_selectedImagePath != null) ...[
            Container(
              margin: const EdgeInsets.all(16.0),
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
            Expanded(child: _buildOCRResults()),
          ] else
            const Expanded(
              child: Center(
                child: Text(
                  'カメラまたはギャラリーから\nレシート画像を選択してください',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ),
        ],
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
          return const Center(
            child: Text(
              '認識された商品がありません。\n別の画像を試してみてください。',
              textAlign: TextAlign.center,
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final isSaved = _savedItems.contains(item.id);
            final selectedType = _itemSelections[item.id];

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              Text(
                                '数量: ${item.quantity}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${item.price.toStringAsFixed(0)}円',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (isSaved)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${selectedType == StorageType.fridge ? '冷蔵庫' : '備蓄品'}に追加済み',
                              style: const TextStyle(color: Colors.green),
                            ),
                          ],
                        ),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _itemSelections[item.id] = StorageType.fridge;
                                });
                                _saveItem(item, StorageType.fridge);
                              },
                              icon: const Icon(Icons.kitchen),
                              label: const Text('冷蔵庫'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _itemSelections[item.id] = StorageType.stock;
                                });
                                _saveItem(item, StorageType.stock);
                              },
                              icon: const Icon(Icons.inventory_2),
                              label: const Text('備蓄品'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'OCR処理中にエラーが発生しました',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(ocrScanProvider(_selectedImagePath!));
              },
              child: const Text('再試行'),
            ),
          ],
        ),
      ),
    );
  }
}
