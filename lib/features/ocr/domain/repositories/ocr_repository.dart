import '../entities/receipt_item.dart';

/// Repository interface for OCR (Optical Character Recognition) operations.
///
/// This repository defines the contract for receipt scanning and processing,
/// including extracting items from receipt images and saving them to storage.
abstract class OCRRepository {
  /// Scans a receipt image and extracts product items.
  ///
  /// Processes the image at the given path using OCR to detect and parse
  /// receipt information, extracting product names, prices, and quantities.
  ///
  /// Parameters:
  ///   [imagePath] - The file path of the receipt image to scan
  ///
  /// Returns a list of [ReceiptItem] objects extracted from the receipt.
  /// Throws an exception if OCR processing fails.
  Future<List<ReceiptItem>> scanReceipt(String imagePath);

  /// Saves receipt items to persistent storage.
  ///
  /// Stores the extracted receipt items for future reference and tracking.
  ///
  /// Parameters:
  ///   [items] - The list of receipt items to save
  ///
  /// Throws an exception if the save operation fails.
  Future<void> saveReceiptItems(List<ReceiptItem> items);
}

