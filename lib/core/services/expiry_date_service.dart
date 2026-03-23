import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

/// Expiry Date Service
///
/// Provides intelligent expiry date estimation for food products using both
/// AI-powered predictions and hardcoded fallback rules. This service helps
/// users manage food freshness by automatically suggesting expiration dates
/// based on product names.
///
/// The service uses a two-tier approach:
/// 1. Primary: AI-powered prediction using Firebase Gemini 2.0 Flash
/// 2. Fallback: Hardcoded rules based on common food categories
///
/// Supported languages: Japanese, Korean, and English
class ExpiryDateService {
  ExpiryDateService._();

  /// Gets expiry days for a product using AI
  ///
  /// Uses Firebase AI (Gemini 2.0 Flash) to estimate the shelf life of a product
  /// based on its name. If AI prediction fails or returns an invalid value,
  /// falls back to the `getDefaultExpiryDays` method.
  ///
  /// Parameters:
  ///   - productName: The name of the product
  ///
  /// Returns: Number of days until expiry (1-365 days)
  static Future<int> getExpiryDaysWithAI(String productName) async {
    try {
      // Firebase AI Logic 초기화 (Gemini Developer API 사용)
      final model = FirebaseAI.googleAI().generativeModel(
        model: 'gemini-2.0-flash',
      );

      // Generate prompt: Request expiry days as a number only
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
        debugPrint('AI response is empty.');
        return getDefaultExpiryDays(productName);
      }

      // Extract numbers only (remove non-numeric characters using regex)
      final days = int.tryParse(text.replaceAll(RegExp(r'[^0-9]'), ''));

      // Validate: Must be between 1 and 365 days
      if (days != null && days > 0 && days <= 365) {
        debugPrint('AI expiry date lookup successful: $productName -> $days days');
        return days;
      } else {
        debugPrint('AI response parsing failed: $text');
      }
    } catch (e) {
      // Use default value if AI call fails
      debugPrint('AI expiry date lookup failed: $e');
    }

    // Fall back to hardcoded values if AI fails
    return getDefaultExpiryDays(productName);
  }

  /// Gets default expiry days based on product name
  ///
  /// Uses hardcoded rules to estimate shelf life based on product categories.
  /// Supports Japanese, Korean, and English product names by checking for
  /// specific keywords in the product name.
  ///
  /// Categories include:
  /// - Dairy products (3-30 days)
  /// - Eggs (21 days)
  /// - Vegetables (3-30 days)
  /// - Fruits (3-14 days)
  /// - Soy products (5-365 days)
  /// - Meat (1-5 days)
  /// - Seafood (1-3 days)
  /// - Bread/Noodles (5-7 days)
  ///
  /// Parameters:
  ///   - productName: The name of the product
  ///
  /// Returns: Number of days until expiry (defaults to 7 days if no match found)
  static int getDefaultExpiryDays(String productName) {
    final name = productName.trim();
    final lowerName = name.toLowerCase();

    // ============================================================
    // SECTION: Dairy Products (3-14 days)
    // ============================================================

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

    // ============================================================
    // SECTION: Eggs (21 days)
    // ============================================================
    if (name.contains('卵') ||
        name.contains('たまご') ||
        name.contains('タマゴ') ||
        lowerName.contains('egg') ||
        name.contains('계란') ||
        name.contains('달걀')) {
      return 21;
    }

    // ============================================================
    // SECTION: Vegetables (3-30 days)
    // ============================================================
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

    // ============================================================
    // SECTION: Fruits (3-14 days)
    // ============================================================
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

    // ============================================================
    // SECTION: Soy Products (5-365 days)
    // ============================================================
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

    // ============================================================
    // SECTION: Meat (1-5 days)
    // ============================================================
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

    // ============================================================
    // SECTION: Fish/Seafood (1-3 days)
    // ============================================================
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

    // ============================================================
    // SECTION: Bread/Noodles (5-7 days)
    // ============================================================
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

    // ============================================================
    // SECTION: Other Japanese Foods
    // ============================================================
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

    // Default: 7 days if no category matches
    return 7;
  }

  /// Gets default expiry date based on product name
  ///
  /// Calculates the expiry date from today by adding the estimated
  /// number of days returned by `getDefaultExpiryDays`.
  ///
  /// Parameters:
  ///   - productName: The name of the product
  ///
  /// Returns: Estimated expiry date
  static DateTime getDefaultExpiryDate(String productName) {
    final days = getDefaultExpiryDays(productName);
    final today = DateTime.now();
    return DateTime(
      today.year,
      today.month,
      today.day,
    ).add(Duration(days: days));
  }

  /// Gets expiry date for a product using AI
  ///
  /// Calculates the expiry date from today by adding the AI-estimated
  /// number of days returned by `getExpiryDaysWithAI`.
  ///
  /// Parameters:
  ///   - productName: The name of the product
  ///
  /// Returns: AI-estimated expiry date
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
