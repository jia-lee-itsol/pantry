import '../entities/barcode_result.dart';
import '../repositories/barcode_repository.dart';

/// 바코드 스캔 유스케이스
class ScanBarcodeUseCase {
  final BarcodeRepository repository;

  ScanBarcodeUseCase(this.repository);

  Future<BarcodeResult?> call(String imagePath) {
    return repository.scanBarcode(imagePath);
  }
}

