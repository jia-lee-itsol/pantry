import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/receipt_item.dart';
import '../../domain/repositories/ocr_repository.dart';
import '../../domain/usecases/scan_receipt_usecase.dart';
import '../../../../core/services/ocr_service.dart';

final ocrScanProvider =
    FutureProvider.family<List<ReceiptItem>, String>((ref, imagePath) async {
  final repository = ref.watch(ocrRepositoryProvider);
  final useCase = ScanReceiptUseCase(repository);
  return useCase(imagePath);
});

final ocrRepositoryProvider = Provider<OCRRepository>((ref) {
  return ref.watch(ocrServiceProvider);
});

