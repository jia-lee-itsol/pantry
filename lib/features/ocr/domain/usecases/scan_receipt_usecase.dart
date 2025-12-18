import '../entities/receipt_item.dart';
import '../repositories/ocr_repository.dart';

class ScanReceiptUseCase {
  final OCRRepository repository;

  ScanReceiptUseCase(this.repository);

  Future<List<ReceiptItem>> call(String imagePath) {
    return repository.scanReceipt(imagePath);
  }
}

