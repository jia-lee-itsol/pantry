import '../../domain/entities/barcode_result.dart';
import '../../domain/repositories/barcode_repository.dart';
import '../datasources/barcode_mlkit_datasource.dart';
import '../models/barcode_result_model.dart';

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

    // Model을 통해 Entity로 변환
    final model = BarcodeResultModel.fromBarcode(barcode);
    return model.toEntity();
  }
}
