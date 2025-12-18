import '../../domain/entities/barcode_result.dart';
import '../../domain/repositories/barcode_repository.dart';
import '../datasources/barcode_mlkit_datasource.dart';

/// 바코드 리포지토리 구현
class BarcodeRepositoryImpl implements BarcodeRepository {
  final BarcodeMLKitDataSource dataSource;

  BarcodeRepositoryImpl(this.dataSource);

  @override
  Future<BarcodeResult?> scanBarcode(String imagePath) async {
    final barcode = await dataSource.scanBarcode(imagePath);
    
    if (barcode == null) {
      return null;
    }

    // 바코드 값만 반환 (상품 정보는 외부 API나 데이터베이스에서 가져올 수 있음)
    return BarcodeResult(barcode: barcode);
  }
}

