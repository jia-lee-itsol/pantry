import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/spacing.dart';
import '../../../ocr/domain/entities/receipt_item.dart';
import '../../../ocr/presentation/providers/ocr_provider.dart';

class OcrReceiptSection extends ConsumerWidget {
  final String? selectedImagePath;
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;
  final void Function(List<ReceiptItem> items) onItemsScanned;

  const OcrReceiptSection({
    super.key,
    this.selectedImagePath,
    required this.onCameraPressed,
    required this.onGalleryPressed,
    required this.onItemsScanned,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: AppSpacing.md),
            _buildActionButtons(),
            if (selectedImagePath != null) ...[
              const SizedBox(height: AppSpacing.md),
              _buildImagePreview(),
              const SizedBox(height: AppSpacing.md),
              _buildOcrResults(context, ref),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
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
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onCameraPressed,
            icon: const Icon(Icons.camera_alt),
            label: const Text('カメラ'),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onGalleryPressed,
            icon: const Icon(Icons.photo_library),
            label: const Text('ギャラリー'),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(selectedImagePath!),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildOcrResults(BuildContext context, WidgetRef ref) {
    final ocrAsync = ref.watch(ocrScanProvider(selectedImagePath!));

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${items.length}個の商品を認識しました',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.green,
                      ),
                ),
                TextButton.icon(
                  onPressed: () {
                    onItemsScanned(List.from(items));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('商品をフォームに追加しました')),
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text('すべて追加'),
                ),
              ],
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
        'OCR処理失敗: $error',
        style: const TextStyle(color: Colors.red),
      ),
    );
  }
}
