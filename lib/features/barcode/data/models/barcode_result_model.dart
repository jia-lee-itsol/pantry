import '../../domain/entities/barcode_result.dart';

/// 바코드 스캔 결과 데이터 모델
class BarcodeResultModel extends BarcodeResult {
  const BarcodeResultModel({
    required super.barcode,
    super.productName,
    super.brand,
    super.category,
  });

  factory BarcodeResultModel.fromJson(Map<String, dynamic> json) {
    return BarcodeResultModel(
      barcode: json['barcode'] as String,
      productName: json['productName'] as String?,
      brand: json['brand'] as String?,
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'barcode': barcode,
      'productName': productName,
      'brand': brand,
      'category': category,
    };
  }

  factory BarcodeResultModel.fromEntity(BarcodeResult entity) {
    return BarcodeResultModel(
      barcode: entity.barcode,
      productName: entity.productName,
      brand: entity.brand,
      category: entity.category,
    );
  }

  BarcodeResult toEntity() {
    return BarcodeResult(
      barcode: barcode,
      productName: productName,
      brand: brand,
      category: category,
    );
  }

  /// 바코드 값만으로 생성
  factory BarcodeResultModel.fromBarcode(String barcode) {
    return BarcodeResultModel(barcode: barcode);
  }
}
