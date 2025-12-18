/// 바코드 스캔 결과 엔티티
class BarcodeResult {
  final String barcode;
  final String? productName;
  final String? brand;
  final String? category;

  const BarcodeResult({
    required this.barcode,
    this.productName,
    this.brand,
    this.category,
  });

  BarcodeResult copyWith({
    String? barcode,
    String? productName,
    String? brand,
    String? category,
  }) {
    return BarcodeResult(
      barcode: barcode ?? this.barcode,
      productName: productName ?? this.productName,
      brand: brand ?? this.brand,
      category: category ?? this.category,
    );
  }
}

