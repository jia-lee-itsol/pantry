import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/receipt_item.dart';
import '../../domain/repositories/ocr_repository.dart';
import '../../domain/usecases/scan_receipt_usecase.dart';
import '../../../../core/services/ocr_service.dart';

// Repository Provider (uses core service)
final ocrRepositoryProvider = Provider<OCRRepository>((ref) {
  return ref.watch(ocrServiceProvider);
});

// UseCase Provider
final scanReceiptUseCaseProvider = Provider<ScanReceiptUseCase>((ref) {
  final repository = ref.watch(ocrRepositoryProvider);
  return ScanReceiptUseCase(repository);
});

// OCR Scan Provider (uses UseCase)
final ocrScanProvider =
    FutureProvider.family<List<ReceiptItem>, String>((ref, imagePath) async {
  final useCase = ref.watch(scanReceiptUseCaseProvider);
  return useCase(imagePath);
});
