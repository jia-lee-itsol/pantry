import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/receipt_item_model.dart';
import 'ocr_remote_datasource.dart';

class OCRGoogleVisionDataSource implements OCRRemoteDataSource {
  static const String _baseUrl =
      'https://vision.googleapis.com/v1/images:annotate';

  String get _apiKey => dotenv.env['GOOGLE_CLOUD_VISION_API_KEY'] ?? '';

  @override
  Future<List<ReceiptItemModel>> scanImage(String imagePath) async {
    try {
      // API 키 확인
      debugPrint(
        '[OCR] API Key loaded: ${_apiKey.isNotEmpty ? "Yes (${_apiKey.substring(0, 10)}...)" : "NO - EMPTY!"}',
      );

      if (_apiKey.isEmpty) {
        throw Exception('API キーが設定されていません。.envファイルを確認してください。');
      }

      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      debugPrint('[OCR] Image size: ${imageBytes.length} bytes');
      debugPrint('[OCR] Sending request to Google Cloud Vision API...');

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'requests': [
            {
              'image': {'content': base64Image},
              'features': [
                {'type': 'TEXT_DETECTION', 'maxResults': 1},
              ],
            },
          ],
        }),
      );

      debugPrint('[OCR] Response status: ${response.statusCode}');
      debugPrint(
        '[OCR] Response body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}',
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Google Cloud Vision API エラー: ${response.statusCode} - ${response.body}',
        );
      }

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final responses = jsonResponse['responses'] as List<dynamic>?;

      if (responses == null || responses.isEmpty) {
        return [];
      }

      final firstResponse = responses[0] as Map<String, dynamic>;
      final textAnnotations =
          firstResponse['textAnnotations'] as List<dynamic>?;

      if (textAnnotations == null || textAnnotations.isEmpty) {
        return [];
      }

      // 첫 번째 항목이 전체 텍스트
      final fullText =
          (textAnnotations[0] as Map<String, dynamic>)['description'] as String;

      return _parseReceiptText(fullText);
    } catch (e) {
      throw Exception('OCR 処理失敗: $e');
    }
  }

  /// 영수증 텍스트를 파싱하여 상품 목록으로 변환
  List<ReceiptItemModel> _parseReceiptText(String text) {
    final items = <ReceiptItemModel>[];
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    final now = DateTime.now();
    int itemIndex = 0;

    debugPrint('[OCR] Total lines: ${lines.length}');
    debugPrint('[OCR] Full text:\n$text');

    // 바로 이전 라인의 상품명 (가격이 다음 라인에 올 수 있음)
    String? previousProductName;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      debugPrint('[OCR] Processing line $i: $line');

      // 비상품 라인 필터링 (가격 체크 전에 먼저 필터링)
      if (_isNonProductLine(line)) {
        debugPrint('[OCR] -> Filtered out (non-product)');
        previousProductName = null; // 비상품 라인을 만나면 이전 상품명 초기화
        continue;
      }

      // 같은 줄에서 상품명+가격 추출 시도
      final productInfo = _extractProductInfo(line);
      if (productInfo != null) {
        debugPrint(
          '[OCR] -> Extracted: ${productInfo['name']} - ${productInfo['price']}円',
        );
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
        previousProductName = null; // 추출 완료했으므로 초기화
        continue;
      }

      // 가격 패턴인지 체크 (*118, ¥270, 숫자만 등)
      double? extractedPrice;
      int extractedQuantity = 1;

      // *가격 패턴 체크 (*118, *270 등) - 편의점 영수증
      final starPriceMatch = RegExp(r'^\*\s*(\d+)$').firstMatch(line);
      if (starPriceMatch != null) {
        extractedPrice = double.tryParse(starPriceMatch.group(1) ?? '');
      }

      // ¥가격 패턴 체크 (¥118, ¥270 등)
      if (extractedPrice == null) {
        final yenPriceMatch = RegExp(r'^[¥￥]\s*(\d+)$').firstMatch(line);
        if (yenPriceMatch != null) {
          extractedPrice = double.tryParse(yenPriceMatch.group(1) ?? '');
        }
      }

      // 가격×수량 패턴 체크 (712X 1, 298×2 등)
      if (extractedPrice == null) {
        final priceQuantityMatch = RegExp(
          r'^(\d+)\s*[X×x]\s*(\d+)$',
        ).firstMatch(line);
        if (priceQuantityMatch != null) {
          extractedPrice = double.tryParse(priceQuantityMatch.group(1) ?? '');
          extractedQuantity =
              int.tryParse(priceQuantityMatch.group(2) ?? '1') ?? 1;
        }
      }

      // 숫자만 있는 가격 패턴 체크 (118, 270 등) - 단, 너무 큰 숫자는 제외
      if (extractedPrice == null) {
        final numberOnlyMatch = RegExp(r'^(\d{2,5})$').firstMatch(line);
        if (numberOnlyMatch != null) {
          final price = double.tryParse(numberOnlyMatch.group(1) ?? '');
          if (price != null && _isValidPrice(price)) {
            extractedPrice = price;
          }
        }
      }

      // 가격을 찾았고 바로 이전 라인이 상품명이면 매칭
      if (extractedPrice != null &&
          _isValidPrice(extractedPrice) &&
          previousProductName != null) {
        debugPrint(
          '[OCR] -> Matched price pattern: $previousProductName - $extractedPrice円 × $extractedQuantity',
        );
        items.add(
          ReceiptItemModel(
            id: 'receipt_item_${now.millisecondsSinceEpoch}_$itemIndex',
            name: previousProductName,
            price: extractedPrice,
            quantity: extractedQuantity,
            purchaseDate: now,
          ),
        );
        itemIndex++;
        previousProductName = null; // 매칭 완료했으므로 초기화
        continue;
      }

      // 상품명일 가능성이 있는 줄인지 확인
      if (_isPossibleProductName(line)) {
        // 가격 패턴이 아니고 상품명일 가능성이 있으면 저장
        if (extractedPrice == null) {
          debugPrint('[OCR] -> Possible product name: $line');
          previousProductName = line;
        } else {
          // 가격 패턴이지만 이전 상품명이 없으면 무시
          debugPrint('[OCR] -> Price pattern but no previous product name');
          previousProductName = null;
        }
      } else {
        debugPrint('[OCR] -> No product info extracted');
        previousProductName = null;
      }
    }

    debugPrint('[OCR] Total items extracted: ${items.length}');
    return items;
  }

  /// 상품명일 가능성이 있는 줄인지 확인
  bool _isPossibleProductName(String line) {
    // 히라가나, 카타카나, 한자가 포함되어 있고
    // 숫자로만 구성되지 않았으며
    // 적절한 길이인 경우
    if (line.length < 2 || line.length > 50) return false;

    // 일본어 문자 포함 확인
    final hasJapanese = RegExp(
      r'[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF]',
    ).hasMatch(line);

    // 영어/숫자 조합 상품명 (예: S500ml)
    final hasAlphanumeric = RegExp(r'[a-zA-Z]').hasMatch(line);

    // 숫자로만 구성된 경우 제외
    final isOnlyNumbers = RegExp(r'^[\d\s,.\-]+$').hasMatch(line);

    return (hasJapanese || hasAlphanumeric) && !isOnlyNumbers;
  }

  /// 텍스트 라인에서 상품 정보 추출 (이름, 가격, 수량)
  Map<String, dynamic>? _extractProductInfo(String line) {
    // 패턴 1: ¥ 또는 ￥ 기호가 있는 경우 (¥298, ￥1,500)
    final yenSymbolRegex = RegExp(r'(.+?)\s*[¥￥]\s*([\d,]+)');
    final yenMatch = yenSymbolRegex.firstMatch(line);
    if (yenMatch != null) {
      final name = _cleanProductName(yenMatch.group(1) ?? '');
      final priceText = yenMatch.group(2)?.replaceAll(',', '') ?? '';
      final price = double.tryParse(priceText);
      if (name.length >= 2 && price != null && _isValidPrice(price)) {
        return {'name': name, 'price': price, 'quantity': 1};
      }
    }

    // 패턴 2: 円 표기가 있는 경우 (298円, 1,500円)
    final enRegex = RegExp(r'(.+?)\s*([\d,]+)\s*円');
    final enMatch = enRegex.firstMatch(line);
    if (enMatch != null) {
      final name = _cleanProductName(enMatch.group(1) ?? '');
      final priceText = enMatch.group(2)?.replaceAll(',', '') ?? '';
      final price = double.tryParse(priceText);
      if (name.length >= 2 && price != null && _isValidPrice(price)) {
        return {'name': name, 'price': price, 'quantity': 1};
      }
    }

    // 패턴 2-1: 상품명 숫자 패턴 (7Pサイダートリプル乳酸菌 500 등)
    final nameNumberRegex = RegExp(r'^(.+?)\s+(\d{2,5})$');
    final nameNumberMatch = nameNumberRegex.firstMatch(line);
    if (nameNumberMatch != null) {
      final name = _cleanProductName(nameNumberMatch.group(1) ?? '');
      final priceText = nameNumberMatch.group(2)?.replaceAll(',', '') ?? '';
      final price = double.tryParse(priceText);
      // 상품명이 적절한 길이이고 가격이 유효한 범위인 경우
      if (name.length >= 3 && price != null && _isValidPrice(price)) {
        return {'name': name, 'price': price, 'quantity': 1};
      }
    }

    // 패턴 3: 상품명 수량 단가 금액 (탭/공백 구분)
    // 예: バナナ    1    100    100
    final multiColumnRegex = RegExp(r'^(.+?)\s+(\d+)\s+([\d,]+)\s+([\d,]+)$');
    final mcMatch = multiColumnRegex.firstMatch(line);
    if (mcMatch != null) {
      final name = _cleanProductName(mcMatch.group(1) ?? '');
      final quantity = int.tryParse(mcMatch.group(2) ?? '1') ?? 1;
      final priceText = mcMatch.group(4)?.replaceAll(',', '') ?? ''; // 마지막이 총액
      final price = double.tryParse(priceText);
      if (name.length >= 2 && price != null && _isValidPrice(price)) {
        return {'name': name, 'price': price, 'quantity': quantity};
      }
    }

    // 패턴 4: 상품명 *수량 가격 또는 상품명 ×수량 가격
    final quantityPriceRegex = RegExp(r'(.+?)\s*[*×xX]\s*(\d+)\s+([\d,]+)');
    final qpMatch = quantityPriceRegex.firstMatch(line);
    if (qpMatch != null) {
      final name = _cleanProductName(qpMatch.group(1) ?? '');
      final quantity = int.tryParse(qpMatch.group(2) ?? '1') ?? 1;
      final priceText = qpMatch.group(3)?.replaceAll(',', '') ?? '';
      final price = double.tryParse(priceText);
      if (name.length >= 2 && price != null && _isValidPrice(price)) {
        return {'name': name, 'price': price, 'quantity': quantity};
      }
    }

    // 패턴 5: 상품명 가격 (공백/탭으로 구분, 숫자로 끝남)
    // 예: "りんご 298" "バナナ 150" "牛乳1L 198"
    final simplePriceRegex = RegExp(r'^(.+?)\s+([\d,]+)$');
    final simpleMatch = simplePriceRegex.firstMatch(line.trim());
    if (simpleMatch != null) {
      final name = _cleanProductName(simpleMatch.group(1) ?? '');
      final priceText = simpleMatch.group(2)?.replaceAll(',', '') ?? '';
      final price = double.tryParse(priceText);
      if (name.length >= 2 && price != null && _isValidPrice(price)) {
        return {'name': name, 'price': price, 'quantity': 1};
      }
    }

    // 패턴 6: 가격이 앞에 오는 경우 (298 りんご)
    final priceFirstRegex = RegExp(r'^([\d,]+)\s+(.+)$');
    final pfMatch = priceFirstRegex.firstMatch(line.trim());
    if (pfMatch != null) {
      final priceText = pfMatch.group(1)?.replaceAll(',', '') ?? '';
      final price = double.tryParse(priceText);
      final name = _cleanProductName(pfMatch.group(2) ?? '');
      if (name.length >= 2 && price != null && _isValidPrice(price)) {
        return {'name': name, 'price': price, 'quantity': 1};
      }
    }

    return null;
  }

  /// 비상품 라인인지 확인
  bool _isNonProductLine(String line) {
    final excludeKeywords = [
      // 가게/연락처 정보
      'TEL', 'FAX', 'tel', 'fax', '電話', '住所', '〒',
      // 등록 정보
      '登録番号', '事業者', '店舗番号', 'レジ番号', 'レジNo', 'レジ #',
      // 날짜/시간 패턴
      '年', '月', '日', '時', '分', '青', '赤', // 青359 같은 시간 코드
      // 결제 관련
      '合計', '小計', '税込', '税抜', '内税', '外税', '消費税', '會計',
      'お預り', 'お釣', '釣銭', '現金', 'クレジット', 'カード払', 'PayPay',
      'ポイント', '割引', '値引', 'クーポン', '支払',
      // 기타
      'レシート', '領収書', 'ありがとう', 'またの', 'お越し',
      'www.', 'http', '@', '.co.jp', '.com',
      // 안내문구
      '保証', '返品', '交換', 'お問い合わせ', 'お買上明細', 'マーク', '軽減税率',
      '会員コード', '伝票番号',
    ];

    // 키워드 체크
    for (final keyword in excludeKeywords) {
      if (line.contains(keyword)) {
        return true;
      }
    }

    // 가게명 패턴 (편의점 체인명)
    final storeNames = [
      'セブン-イレブン',
      'セブンイレブン',
      'ファミリーマート',
      'ローソン',
      'ミニストップ',
      'デイリーヤマザキ',
      'ポプラ',
      'スリーエフ',
    ];
    for (final storeName in storeNames) {
      if (line.contains(storeName) && !RegExp(r'\d{3,}').hasMatch(line)) {
        return true; // 숫자가 포함되지 않은 순수 가게명만 필터링
      }
    }

    // 가게 주소 패턴 (都道府県, 市, 区 등)
    if (RegExp(r'[都道府県市区町村]').hasMatch(line) &&
        (line.contains('県') || line.contains('市') || line.contains('区'))) {
      return true;
    }

    // 전화번호 패턴 (045-243-xxxx 등)
    if (RegExp(r'\d{2,4}-\d{2,4}-\d{2,4}').hasMatch(line)) return true;

    // 날짜 패턴 (2025年12月21日, 2025/12/21, 12/21 등)
    if (RegExp(r'\d{1,4}[年月/]\d{1,2}[月日/]\d{1,4}').hasMatch(line)) return true;
    if (RegExp(r'\d{1,4}/\d{1,2}/\d{1,4}').hasMatch(line)) return true;

    // 시간 패턴 (17:30, 10:48 등)
    if (RegExp(r'\d{1,2}:\d{2}').hasMatch(line)) return true;

    // T로 시작하는 등록번호 (T7020002059068)
    if (RegExp(r'^T\d{10,}').hasMatch(line)) return true;

    // 숫자만 있는 라인 (바코드 등) - 단, 짧은 가격은 제외
    if (RegExp(r'^[\d\s\-]+$').hasMatch(line.trim()) && line.length > 5)
      return true;

    // 너무 긴 숫자 (10자리 이상)
    if (RegExp(r'\d{10,}').hasMatch(line)) return true;

    // 너무 짧은 라인 (2자 이하)
    if (line.trim().length <= 2) return true;

    // 괄호로 시작하고 가게명 패턴
    if (RegExp(r'^\[.+\]').hasMatch(line) &&
        !RegExp(r'\d{2,}').hasMatch(line.split(']').last)) {
      return true;
    }

    // 별표와 숫자만 있는 라인은 가격이므로 상품명이 아님 (하지만 필터링하지 않음)
    // if (RegExp(r'^\*\d+$').hasMatch(line)) return false;

    // 회원코드 패턴 (****-****-*****-20049)
    if (RegExp(r'\*{4,}').hasMatch(line) && RegExp(r'\d+').hasMatch(line))
      return true;

    return false;
  }

  /// 상품명 정리
  String _cleanProductName(String name) {
    return name
        .replaceAll(RegExp(r'^\s*[*×xX]\s*\d+\s*'), '') // 앞쪽 수량 제거
        .replaceAll(RegExp(r'[\[\]【】]'), '') // 괄호 제거
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// 유효한 가격인지 확인 (50엔 ~ 50,000엔 범위)
  bool _isValidPrice(double price) {
    return price >= 50 && price <= 50000;
  }
}
