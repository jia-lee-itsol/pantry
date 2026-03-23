/// Domain entity representing the result of a barcode scan operation.
///
/// This entity encapsulates the barcode value along with optional product
/// information that may be retrieved from external APIs or databases.
class BarcodeResult {
  /// The scanned barcode value (e.g., EAN-13, UPC-A, etc.)
  final String barcode;

  /// The name of the product associated with the barcode
  final String? productName;

  /// The brand or manufacturer of the product
  final String? brand;

  /// The category or type of product
  final String? category;

  /// Creates a [BarcodeResult] instance.
  ///
  /// The [barcode] parameter is required, while product details are optional
  /// as they may not always be available.
  const BarcodeResult({
    required this.barcode,
    this.productName,
    this.brand,
    this.category,
  });

  /// Creates a copy of this [BarcodeResult] with the given fields replaced.
  ///
  /// Returns a new [BarcodeResult] instance with updated values for any
  /// non-null parameters, keeping existing values for null parameters.
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

