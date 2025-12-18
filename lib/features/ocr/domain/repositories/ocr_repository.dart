import '../entities/receipt_item.dart';

abstract class OCRRepository {
  Future<List<ReceiptItem>> scanReceipt(String imagePath);
  Future<void> saveReceiptItems(List<ReceiptItem> items);
}

