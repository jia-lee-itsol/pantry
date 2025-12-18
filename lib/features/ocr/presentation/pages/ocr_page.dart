import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/ocr_provider.dart';

class OCRPage extends ConsumerStatefulWidget {
  const OCRPage({super.key});

  @override
  ConsumerState<OCRPage> createState() => _OCRPageState();
}

class _OCRPageState extends ConsumerState<OCRPage> {
  final ImagePicker _imagePicker = ImagePicker();
  String? _selectedImagePath;

  Future<void> _pickImage() async {
    try {
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

  Future<void> _pickImageFromGallery() async {
    try {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('レシートOCR')),
      body: Column(
        children: [
          // 이미지 선택 버튼
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

          // 선택된 이미지 표시
          if (_selectedImagePath != null) ...[
            Container(
              margin: const EdgeInsets.all(16.0),
              height: 200,
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

            // OCR 결과 표시
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
            return Card(
              child: ListTile(
                title: Text(item.name),
                subtitle: Text('数量: ${item.quantity}'),
                trailing: Text(
                  '${item.price.toStringAsFixed(0)}円',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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
