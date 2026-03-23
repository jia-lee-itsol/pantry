import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/receipt_item.dart';
import '../../domain/repositories/ocr_repository.dart';
import '../../domain/usecases/scan_receipt_usecase.dart';
import '../../../../core/services/ocr_service.dart';

/// Provider for the OCR repository.
///
/// Exposes the [OCRRepository] interface, implemented by the core
/// OCR service. Enables dependency injection for OCR operations.
final ocrRepositoryProvider = Provider<OCRRepository>((ref) {
  return ref.watch(ocrServiceProvider);
});

/// Provider for the scan receipt use case.
///
/// Creates an instance of [ScanReceiptUseCase] with the injected
/// OCR repository, following clean architecture principles.
final scanReceiptUseCaseProvider = Provider<ScanReceiptUseCase>((ref) {
  final repository = ref.watch(ocrRepositoryProvider);
  return ScanReceiptUseCase(repository);
});

/// Provider for OCR receipt scanning operations.
///
/// A family provider that accepts an image path and returns extracted
/// receipt items. Executes the OCR scanning use case and handles
/// loading/error states automatically through Riverpod's AsyncValue.
///
/// Parameters:
///   [imagePath] - The file path of the receipt image to scan
///
/// Returns a list of [ReceiptItem] objects extracted from the receipt.
final ocrScanProvider =
    FutureProvider.family<List<ReceiptItem>, String>((ref, imagePath) async {
  final useCase = ref.watch(scanReceiptUseCaseProvider);
  return useCase(imagePath);
});
