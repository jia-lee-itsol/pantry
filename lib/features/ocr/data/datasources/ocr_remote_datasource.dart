import '../models/receipt_item_model.dart';

abstract class OCRRemoteDataSource {
  Future<List<ReceiptItemModel>> scanImage(String imagePath);
}

