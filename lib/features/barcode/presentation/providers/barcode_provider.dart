import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/barcode_result.dart';
import '../../domain/repositories/barcode_repository.dart';
import '../../domain/usecases/scan_barcode_usecase.dart';
import '../../../../core/services/barcode_service.dart';

/// Provider for the barcode repository.
///
/// Exposes the [BarcodeRepository] interface, implemented by the core
/// barcode service. Enables dependency injection for barcode operations.
final barcodeRepositoryProvider = Provider<BarcodeRepository>((ref) {
  return ref.watch(barcodeServiceProvider);
});

/// Provider for the scan barcode use case.
///
/// Creates an instance of [ScanBarcodeUseCase] with the injected
/// barcode repository, following clean architecture principles.
final scanBarcodeUseCaseProvider = Provider<ScanBarcodeUseCase>((ref) {
  final repository = ref.watch(barcodeRepositoryProvider);
  return ScanBarcodeUseCase(repository);
});

/// Provider for barcode scanning operations.
///
/// A family provider that accepts an image path and returns the scan result.
/// Executes the barcode scanning use case and handles loading/error states
/// automatically through Riverpod's AsyncValue.
///
/// Parameters:
///   [imagePath] - The file path of the image to scan
///
/// Returns a [BarcodeResult] if a barcode is found, null otherwise.
final barcodeScanProvider =
    FutureProvider.family<BarcodeResult?, String>((ref, imagePath) async {
  final useCase = ref.watch(scanBarcodeUseCaseProvider);
  return await useCase(imagePath);
});

