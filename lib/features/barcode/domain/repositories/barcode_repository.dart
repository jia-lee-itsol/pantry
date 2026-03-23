import '../entities/barcode_result.dart';

/// Repository interface for barcode scanning operations.
///
/// This repository defines the contract for barcode-related functionality,
/// including scanning barcodes from images and retrieving product information.
abstract class BarcodeRepository {
  /// Scans a barcode from an image file.
  ///
  /// Processes the image at the given path to detect and decode barcodes.
  /// May also fetch product information associated with the barcode.
  ///
  /// Parameters:
  ///   [imagePath] - The file path of the image to scan
  ///
  /// Returns a [BarcodeResult] containing the barcode and product info,
  /// or null if no barcode is detected.
  Future<BarcodeResult?> scanBarcode(String imagePath);
}

