import '../entities/barcode_result.dart';

/// 바코드 리포지토리 인터페이스
abstract class BarcodeRepository {
  /// 이미지에서 바코드를 스캔합니다.
  ///
  /// [imagePath]: 스캔할 이미지 경로
  ///
  /// 반환: 바코드 스캔 결과
  Future<BarcodeResult?> scanBarcode(String imagePath);
}

