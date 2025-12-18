import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

class ExpiryDateService {
  ExpiryDateService._();

  /// AI를 사용하여 상품명 기반 유통기한(일수)을 검색합니다.
  ///
  /// Firebase AI (Gemini 2.0 Flash)를 사용하여 상품명으로 유통기한을 검색합니다.
  /// AI 호출이 실패하거나 응답을 파싱할 수 없는 경우,
  /// 하드코딩된 규칙을 사용하는 `getDefaultExpiryDays` 메서드를 호출합니다.
  ///
  /// 파라미터:
  /// - [productName]: 상품명
  ///
  /// 반환: 유통기한 일수 (1-365일 사이의 값)
  static Future<int> getExpiryDaysWithAI(String productName) async {
    try {
      // Firebase AI Logic 초기화 (Gemini Developer API 사용)
      final model = FirebaseAI.googleAI().generativeModel(
        model: 'gemini-2.0-flash',
      );

      // 프롬프트 생성: 일본어로 유통기한을 일수로만 답변하도록 요청
      final promptText =
          '''
以下の食品を冷蔵保存する場合の一般的な消費期限を日数で数字のみで答えてください。
食品名: $productName

回答形式: 数字のみ (例: 7, 14, 21など)
''';

      final prompt = [Content.text(promptText)];
      final response = await model.generateContent(prompt);
      final text = response.text?.trim() ?? '';

      if (text.isEmpty) {
        debugPrint('AI応答が空です。');
        return getDefaultExpiryDays(productName);
      }

      // 숫자만 추출 (정규식을 사용하여 숫자가 아닌 문자 제거)
      final days = int.tryParse(text.replaceAll(RegExp(r'[^0-9]'), ''));

      // 유효성 검증: 1일 이상 365일 이하인지 확인
      if (days != null && days > 0 && days <= 365) {
        debugPrint('AI消費期限検索成功: $productName -> $days日');
        return days;
      } else {
        debugPrint('AI応答パース失敗: $text');
      }
    } catch (e) {
      // AI 호출 실패 시 기본값 사용
      debugPrint('AI消費期限検索失敗: $e');
    }

    // AI 실패 시 하드코딩된 값 사용
    return getDefaultExpiryDays(productName);
  }

  /// 상품명을 기반으로 기본 유통기한(일수)을 반환합니다.
  ///
  /// 하드코딩된 규칙을 사용하여 상품명으로 유통기한을 계산합니다.
  /// 일본어, 한국어, 영어를 지원하며, 상품명에 특정 키워드가 포함되어 있는지 확인합니다.
  /// 매칭되는 카테고리가 없으면 기본값인 7일을 반환합니다.
  ///
  /// 파라미터:
  /// - [productName]: 상품명
  ///
  /// 반환: 유통기한 일수
  ///
  /// 참고: 당일 기준으로 추가된 경우를 가정합니다.
  static int getDefaultExpiryDays(String productName) {
    // 일본어는 대소문자가 없으므로 원본과 소문자 모두 체크
    // 한국어, 영어 대응을 위해 소문자 변환도 함께 수행
    final name = productName.trim();
    final lowerName = name.toLowerCase();

    // 유제품 (3-14일)
    if (name.contains('牛乳') ||
        lowerName.contains('milk') ||
        name.contains('우유') ||
        name.contains('ミルク')) {
      return 7;
    }
    if (name.contains('ヨーグルト') ||
        lowerName.contains('yogurt') ||
        name.contains('요구르트') ||
        name.contains('요거트')) {
      return 7;
    }
    if (name.contains('チーズ') ||
        lowerName.contains('cheese') ||
        name.contains('치즈')) {
      return 14;
    }
    if (name.contains('バター') || lowerName.contains('butter')) {
      return 30;
    }
    if (name.contains('生クリーム') || lowerName.contains('cream')) {
      return 5;
    }

    // 계란 (14-21일)
    if (name.contains('卵') ||
        name.contains('たまご') ||
        name.contains('タマゴ') ||
        lowerName.contains('egg') ||
        name.contains('계란') ||
        name.contains('달걀')) {
      return 21;
    }

    // 채소 (3-30일)
    if (name.contains('レタス') ||
        lowerName.contains('lettuce') ||
        name.contains('상추') ||
        name.contains('채소')) {
      return 5;
    }
    if (name.contains('キャベツ') || lowerName.contains('cabbage')) {
      return 7;
    }
    if (name.contains('トマト') || lowerName.contains('tomato')) {
      return 7;
    }
    if (name.contains('きゅうり') ||
        name.contains('キュウリ') ||
        lowerName.contains('cucumber')) {
      return 7;
    }
    if (name.contains('ほうれん草') ||
        name.contains('ホウレンソウ') ||
        lowerName.contains('spinach')) {
      return 5;
    }
    if (name.contains('もやし') || name.contains('モヤシ')) {
      return 3;
    }
    if (name.contains('白菜') || name.contains('ハクサイ')) {
      return 7;
    }
    if (name.contains('ブロッコリー') || lowerName.contains('broccoli')) {
      return 7;
    }
    if (name.contains('にんじん') ||
        name.contains('ニンジン') ||
        lowerName.contains('carrot') ||
        name.contains('당근')) {
      return 14;
    }
    if (name.contains('玉ねぎ') ||
        name.contains('タマネギ') ||
        name.contains('玉葱') ||
        lowerName.contains('onion') ||
        name.contains('양파')) {
      return 30;
    }
    if (name.contains('じゃがいも') ||
        name.contains('ジャガイモ') ||
        name.contains('馬鈴薯') ||
        lowerName.contains('potato') ||
        name.contains('감자')) {
      return 30;
    }

    // 과일 (3-14일)
    if (name.contains('りんご') ||
        name.contains('リンゴ') ||
        name.contains('林檎') ||
        lowerName.contains('apple') ||
        name.contains('사과')) {
      return 14;
    }
    if (name.contains('バナナ') ||
        lowerName.contains('banana') ||
        name.contains('바나나')) {
      return 5;
    }
    if (name.contains('いちご') ||
        name.contains('イチゴ') ||
        name.contains('苺') ||
        lowerName.contains('strawberry') ||
        name.contains('딸기')) {
      return 3;
    }
    if (name.contains('みかん') ||
        name.contains('ミカン') ||
        name.contains('蜜柑') ||
        lowerName.contains('orange') ||
        lowerName.contains('mandarin')) {
      return 14;
    }
    if (name.contains('ぶどう') ||
        name.contains('ブドウ') ||
        name.contains('葡萄') ||
        lowerName.contains('grape')) {
      return 7;
    }
    if (name.contains('メロン') || lowerName.contains('melon')) {
      return 7;
    }
    if (name.contains('スイカ') ||
        name.contains('西瓜') ||
        lowerName.contains('watermelon')) {
      return 7;
    }
    if (name.contains('梨') ||
        name.contains('ナシ') ||
        lowerName.contains('pear')) {
      return 7;
    }
    if (name.contains('桃') ||
        name.contains('モモ') ||
        lowerName.contains('peach')) {
      return 5;
    }

    // 콩제품 (3-180일)
    if (name.contains('豆腐') ||
        name.contains('トウフ') ||
        lowerName.contains('tofu') ||
        name.contains('두부') ||
        name.contains('콩')) {
      return 5;
    }
    if (name.contains('納豆') || name.contains('ナットウ')) {
      return 7;
    }
    if (name.contains('味噌') || name.contains('ミソ')) {
      return 180;
    }
    if (name.contains('醤油') || name.contains('ショウユ')) {
      return 365;
    }

    // 육류 (1-5일)
    if (name.contains('鶏肉') ||
        name.contains('とり肉') ||
        name.contains('チキン') ||
        name.contains('ささみ') ||
        name.contains('ササミ') ||
        lowerName.contains('chicken') ||
        name.contains('닭') ||
        name.contains('고기') ||
        lowerName.contains('meat')) {
      return 3;
    }
    if (name.contains('豚肉') ||
        name.contains('ぶた肉') ||
        name.contains('ポーク') ||
        lowerName.contains('pork') ||
        name.contains('돼지')) {
      return 3;
    }
    if (name.contains('牛肉') ||
        name.contains('ぎゅうにく') ||
        name.contains('ビーフ') ||
        lowerName.contains('beef') ||
        name.contains('소고기')) {
      return 3;
    }
    if (name.contains('ひき肉') ||
        name.contains('挽き肉') ||
        name.contains('ミンチ') ||
        lowerName.contains('ground') ||
        lowerName.contains('minced')) {
      return 1;
    }
    if (name.contains('ハム') || lowerName.contains('ham')) {
      return 5;
    }
    if (name.contains('ソーセージ') || lowerName.contains('sausage')) {
      return 5;
    }

    // 생선/해산물 (1-3일)
    if (name.contains('魚') ||
        name.contains('さかな') ||
        name.contains('サカナ') ||
        lowerName.contains('fish') ||
        name.contains('생선')) {
      return 2;
    }
    if (name.contains('刺身') ||
        name.contains('さしみ') ||
        name.contains('サシミ') ||
        lowerName.contains('sashimi')) {
      return 1;
    }
    if (name.contains('サーモン') ||
        name.contains('鮭') ||
        name.contains('さけ') ||
        name.contains('연어') ||
        lowerName.contains('salmon')) {
      return 2;
    }
    if (name.contains('マグロ') ||
        name.contains('鮪') ||
        name.contains('まぐろ') ||
        lowerName.contains('tuna')) {
      return 2;
    }
    if (name.contains('えび') ||
        name.contains('エビ') ||
        name.contains('海老') ||
        lowerName.contains('shrimp') ||
        lowerName.contains('prawn')) {
      return 2;
    }
    if (name.contains('いか') ||
        name.contains('イカ') ||
        name.contains('烏賊') ||
        lowerName.contains('squid')) {
      return 2;
    }
    if (name.contains('たこ') ||
        name.contains('タコ') ||
        name.contains('蛸') ||
        lowerName.contains('octopus')) {
      return 2;
    }

    // 빵/면류 (2-7일)
    if (name.contains('パン') ||
        lowerName.contains('bread') ||
        name.contains('빵')) {
      return 5;
    }
    if (name.contains('うどん') ||
        name.contains('ウドン') ||
        lowerName.contains('udon')) {
      return 7;
    }
    if (name.contains('そば') ||
        name.contains('ソバ') ||
        name.contains('蕎麦') ||
        lowerName.contains('soba')) {
      return 7;
    }
    if (name.contains('パスタ') ||
        name.contains('スパゲッティ') ||
        lowerName.contains('pasta') ||
        lowerName.contains('spaghetti')) {
      return 7;
    }
    if (name.contains('ラーメン') || lowerName.contains('ramen')) {
      return 7;
    }

    // 기타 일본 식품
    if (name.contains('もずく') || name.contains('モズク')) {
      return 3;
    }
    if (name.contains('わかめ') || name.contains('ワカメ') || name.contains('若布')) {
      return 5;
    }
    if (name.contains('漬物') || name.contains('つけもの') || name.contains('ツケモノ')) {
      return 14;
    }
    if (name.contains('みりん') || name.contains('ミリン')) {
      return 365;
    }
    if (name.contains('だし') || name.contains('ダシ') || name.contains('出汁')) {
      return 30;
    }

    // 기본값: 7일
    return 7;
  }

  /// 상품명을 기반으로 당일 기준 유통기한 날짜를 반환합니다.
  static DateTime getDefaultExpiryDate(String productName) {
    final days = getDefaultExpiryDays(productName);
    final today = DateTime.now();
    return DateTime(
      today.year,
      today.month,
      today.day,
    ).add(Duration(days: days));
  }

  /// AI를 사용하여 상품명 기반 유통기한 날짜를 반환합니다.
  static Future<DateTime> getExpiryDateWithAI(String productName) async {
    final days = await getExpiryDaysWithAI(productName);
    final today = DateTime.now();
    return DateTime(
      today.year,
      today.month,
      today.day,
    ).add(Duration(days: days));
  }
}
