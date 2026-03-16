import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/spacing.dart';
import '../../../barcode/presentation/providers/barcode_provider.dart';

class BarcodeScanSection extends ConsumerWidget {
  final String? barcodeImagePath;
  final VoidCallback onScanPressed;
  final void Function(String barcode) onBarcodeApplied;

  const BarcodeScanSection({
    super.key,
    this.barcodeImagePath,
    required this.onScanPressed,
    required this.onBarcodeApplied,
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
            _buildScanButton(),
            if (barcodeImagePath != null) ...[
              const SizedBox(height: AppSpacing.md),
              _buildImagePreview(),
              const SizedBox(height: AppSpacing.md),
              _buildScanResult(context, ref),
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
          Icons.qr_code_scanner,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'バーコードスキャン',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget _buildScanButton() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onScanPressed,
            icon: const Icon(Icons.camera_alt),
            label: const Text('バーコードスキャン'),
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
          File(barcodeImagePath!),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildScanResult(BuildContext context, WidgetRef ref) {
    final barcodeAsync = ref.watch(barcodeScanProvider(barcodeImagePath!));

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
              onPressed: () => onBarcodeApplied(result.barcode),
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
}
