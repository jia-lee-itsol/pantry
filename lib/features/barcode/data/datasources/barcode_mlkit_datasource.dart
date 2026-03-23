
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:flutter/foundation.dart';

/// Data source for barcode scanning using Google ML Kit.
///
/// This class provides barcode detection and decoding functionality
/// using the ML Kit Barcode Scanning API. It supports various barcode
/// formats including EAN-13, EAN-8, UPC-A, UPC-E, and more.
class BarcodeMLKitDataSource {
  final BarcodeScanner _barcodeScanner;

  /// Creates a [BarcodeMLKitDataSource] with ML Kit barcode scanner.
  ///
  /// Initializes the scanner to recognize all supported barcode formats.
  BarcodeMLKitDataSource()
      : _barcodeScanner = BarcodeScanner(formats: [
          BarcodeFormat.all,
        ]);

  /// Scans and extracts barcode values from an image.
  ///
  /// Uses ML Kit to process the image and detect barcodes. If multiple
  /// barcodes are found, returns the first one detected.
  ///
  /// Parameters:
  ///   [imagePath] - The file path of the image to scan
  ///
  /// Returns the barcode value as a string (e.g., "1234567890123" for EAN-13),
  /// or null if no barcode is detected or the value is empty.
  ///
  /// Throws an exception if image processing fails.
  Future<String?> scanBarcode(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final List<Barcode> barcodes =
          await _barcodeScanner.processImage(inputImage);

      if (barcodes.isEmpty) {
        debugPrint('No barcode found in the image.');
        return null;
      }

      // Return the first detected barcode
      final barcode = barcodes.first;
      final barcodeValue = barcode.displayValue ?? barcode.rawValue;

      if (barcodeValue == null || barcodeValue.isEmpty) {
        debugPrint('Barcode value is empty.');
        return null;
      }

      debugPrint('Barcode scan successful: $barcodeValue');
      return barcodeValue;
    } catch (e) {
      debugPrint('Barcode scan failed: $e');
      rethrow;
    }
  }

  /// Releases resources used by the barcode scanner.
  ///
  /// Should be called when the scanner is no longer needed to free up memory.
  void dispose() {
    _barcodeScanner.close();
  }
}

