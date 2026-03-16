/// Use Case for guessing category from item name.
/// Contains business logic for category inference based on keywords.
class GuessCategoryUseCase {
  static const List<String> categoryOrder = [
    '飲料水/飲み物',
    '主食類',
    '缶詰/加工食品',
    '乳製品',
    'その他',
  ];

  String call(String name) {
    final lowerName = name.toLowerCase();

    // 通조림/가공식품 (더 구체적인 카테고리를 먼저 확인)
    if (lowerName.contains('缶詰') ||
        (lowerName.contains('缶') && !lowerName.contains('飲料')) ||
        lowerName.contains('canned')) {
      return '缶詰/加工食品';
    }

    // 飲料水/飲み物
    if (lowerName.contains('水') ||
        lowerName.contains('飲料') ||
        (lowerName.contains('缶') && lowerName.contains('飲料')) ||
        lowerName.contains('drink') ||
        lowerName.contains('water')) {
      return '飲料水/飲み物';
    }

    // 主食類
    if (lowerName.contains('米') ||
        lowerName.contains('ラーメン') ||
        lowerName.contains('乾パン') ||
        lowerName.contains('rice') ||
        lowerName.contains('noodle') ||
        lowerName.contains('ramen')) {
      return '主食類';
    }

    // 乳製品
    if (lowerName.contains('牛乳') ||
        lowerName.contains('チーズ') ||
        lowerName.contains('milk') ||
        lowerName.contains('cheese')) {
      return '乳製品';
    }

    // その他
    return 'その他';
  }
}
