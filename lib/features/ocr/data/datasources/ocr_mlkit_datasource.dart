import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../models/receipt_item_model.dart';
import 'ocr_remote_datasource.dart';

class OCRMLKitDataSource implements OCRRemoteDataSource {
  final TextRecognizer _textRecognizer;

  OCRMLKitDataSource() : _textRecognizer = TextRecognizer();

  @override
  Future<List<ReceiptItemModel>> scanImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      return _parseReceiptText(recognizedText.text);
    } catch (e) {
      throw Exception('OCR 처리 실패: $e');
    }
  }

  /// 영수증 텍스트를 파싱하여 상품 목록으로 변환
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

  /// 텍스트 라인에서 상품 정보 추출 (이름, 가격, 수량)
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

  void dispose() {
    _textRecognizer.close();
  }
}

