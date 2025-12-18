import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/barcode_result.dart';
import '../../domain/repositories/barcode_repository.dart';
import '../../domain/usecases/scan_barcode_usecase.dart';
import '../../../../core/services/barcode_service.dart';

/// 바코드 리포지토리 프로바이더
final barcodeRepositoryProvider = Provider<BarcodeRepository>((ref) {
  return ref.watch(barcodeServiceProvider);
});

/// 바코드 스캔 유스케이스 프로바이더
final scanBarcodeUseCaseProvider = Provider<ScanBarcodeUseCase>((ref) {
  final repository = ref.watch(barcodeRepositoryProvider);
  return ScanBarcodeUseCase(repository);
});

/// 바코드 스캔 프로바이더
final barcodeScanProvider =
    FutureProvider.family<BarcodeResult?, String>((ref, imagePath) async {
  final useCase = ref.watch(scanBarcodeUseCaseProvider);
  return await useCase(imagePath);
});

