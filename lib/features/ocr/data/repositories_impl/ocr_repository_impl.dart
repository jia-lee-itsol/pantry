import '../../domain/entities/receipt_item.dart';
import '../../domain/repositories/ocr_repository.dart';
import '../datasources/ocr_remote_datasource.dart';
import '../../../fridge/domain/entities/fridge_item.dart';
import '../../../fridge/domain/repositories/fridge_repository.dart';
import '../../../../core/services/expiry_date_service.dart';

class OCRRepositoryImpl implements OCRRepository {
  final OCRRemoteDataSource remoteDataSource;
  final FridgeRepository fridgeRepository;

  OCRRepositoryImpl(
    this.remoteDataSource,
    this.fridgeRepository,
  );

  @override
  Future<List<ReceiptItem>> scanReceipt(String imagePath) async {
    return await remoteDataSource.scanImage(imagePath);
  }

  @override
  Future<void> saveReceiptItems(List<ReceiptItem> items) async {
    try {
      for (final receiptItem in items) {
        // AI를 사용하여 유통기한 추정 (실패 시 기본값 사용)
        final expiryDate = await ExpiryDateService.getExpiryDateWithAI(
          receiptItem.name,
        );

        final fridgeItem = FridgeItem(
          id: '${DateTime.now().millisecondsSinceEpoch}_${receiptItem.id}',
          name: receiptItem.name,
          quantity: receiptItem.quantity,
          category: null, // 카테고리는 자동 분류가 어려우므로 null
          expiryDate: expiryDate,
          createdAt: DateTime.now(),
        );

        await fridgeRepository.addFridgeItem(fridgeItem);
      }
    } catch (e) {
      throw Exception('レシートアイテムの保存に失敗しました: $e');
    }
  }
}

