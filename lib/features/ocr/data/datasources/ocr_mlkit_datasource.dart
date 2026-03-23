import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../models/receipt_item_model.dart';
import 'ocr_remote_datasource.dart';

/// Data source for OCR processing using Google ML Kit.
///
/// This class provides text recognition functionality using the ML Kit
/// Text Recognition API. It processes receipt images to extract text
/// and parse product information.
class OCRMLKitDataSource implements OCRRemoteDataSource {
  final TextRecognizer _textRecognizer;

  /// Creates an [OCRMLKitDataSource] with ML Kit text recognizer.
  OCRMLKitDataSource() : _textRecognizer = TextRecognizer();

  /// Scans an image and extracts receipt items using ML Kit OCR.
  ///
  /// Performs text recognition on the image and parses the extracted text
  /// to identify product items with their names, prices, and quantities.
  ///
  /// Parameters:
  ///   [imagePath] - The file path of the receipt image to scan
  ///
  /// Returns a list of [ReceiptItemModel] objects parsed from the image.
  /// Throws an exception if OCR processing fails.
  @override
  Future<List<ReceiptItemModel>> scanImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      return _parseReceiptText(recognizedText.text);
    } catch (e) {
      throw Exception('OCR processing failed: $e');
    }
  }

  /// Parses receipt text to extract product information.
  ///
  /// Analyzes the OCR-extracted text line by line to identify products,
  /// prices, and quantities using pattern matching.
  ///
  /// Parameters:
  ///   [text] - The raw text extracted from the receipt
  ///
  /// Returns a list of [ReceiptItemModel] objects.
  List<ReceiptItemModel> _parseReceiptText(String text) {
    final items = <ReceiptItemModel>[];
    final lines = text.split('\n');
    final now = DateTime.now();
    int itemIndex = 0;

    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;

      // 영수증에서 상품명과 가격을 추출하는 로직
      // 예: "사과 3,000원", "바나나\t5,000", "우유 2000원" 등
      final productInfo = _extractProductInfo(trimmedLine);
      if (productInfo != null) {
        items.add(
          ReceiptItemModel(
            id: 'receipt_item_${now.millisecondsSinceEpoch}_$itemIndex',
            name: productInfo['name'] as String,
            price: productInfo['price'] as double,
            quantity: productInfo['quantity'] as int,
            purchaseDate: now,
          ),
        );
        itemIndex++;
      }
    }

    return items;
  }

  /// Extracts product information from a text line.
  ///
  /// Attempts to parse a line of text to extract product name, price,
  /// and quantity using regex patterns for Korean receipts.
  ///
  /// Parameters:
  ///   [line] - A single line of text from the receipt
  ///
  /// Returns a map containing 'name', 'price', and 'quantity' keys,
  /// or null if no valid product information is found.
  Map<String, dynamic>? _extractProductInfo(String line) {
    // 숫자 제거 (가격 추출용)
    final priceRegex = RegExp(r'[\d,]+원?');
    final priceMatches = priceRegex.allMatches(line);

    if (priceMatches.isEmpty) return null;

    // 마지막 숫자가 가격일 가능성이 높음
    final lastPriceMatch = priceMatches.last;
    final priceText = lastPriceMatch.group(0)!
        .replaceAll(',', '')
        .replaceAll('원', '');
    final price = double.tryParse(priceText);

    if (price == null || price <= 0) return null;

    // 가격을 제외한 부분이 상품명
    final name = line
        .substring(0, lastPriceMatch.start)
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');

    if (name.isEmpty || name.length < 2) return null;

    // 수량 추출 시도 (앞쪽 숫자)
    int quantity = 1;
    if (priceMatches.length > 1) {
      final firstNumberText = priceMatches.first.group(0)!
          .replaceAll(',', '')
          .replaceAll('원', '');
      final firstNumber = int.tryParse(firstNumberText);
      if (firstNumber != null && firstNumber > 0 && firstNumber < 100) {
        quantity = firstNumber;
      }
    }

    return {
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  /// Releases resources used by the text recognizer.
  ///
  /// Should be called when the OCR processor is no longer needed.
  void dispose() {
    _textRecognizer.close();
  }
}

