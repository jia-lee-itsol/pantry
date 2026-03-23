// ============================================
// Guess Category Use Case
// ============================================

/// Use case for automatically inferring item category from its name.
///
/// This use case implements intelligent category detection based on keyword
/// matching. It analyzes the item name and assigns an appropriate category
/// from a predefined set.
///
/// Categories include:
/// - Beverages (飲料水/飲み物)
/// - Staple Foods (主食類)
/// - Canned/Processed Foods (缶詰/加工食品)
/// - Dairy Products (乳製品)
/// - Others (その他)
///
/// Usage:
/// ```dart
/// final useCase = GuessCategoryUseCase();
/// final category = useCase('Bottled Water');
/// // Returns: '飲料水/飲み物'
/// ```
class GuessCategoryUseCase {
  /// Predefined order of categories for consistent sorting across the application.
  ///
  /// This order determines how categories are displayed in grouped views.
  static const List<String> categoryOrder = [
    '飲料水/飲み物',
    '主食類',
    '缶詰/加工食品',
    '乳製品',
    'その他',
  ];

  /// Executes the use case to guess the category from an item name.
  ///
  /// The method performs case-insensitive keyword matching against common
  /// food and beverage terms in both Japanese and English.
  ///
  /// Parameters:
  /// - [name]: The name of the item to categorize
  ///
  /// Returns the most appropriate category string. If no specific category
  /// matches, returns 'その他' (Others).
  String call(String name) {
    final lowerName = name.toLowerCase();

    // Canned/Processed Foods (check more specific category first)
    if (lowerName.contains('缶詰') ||
        (lowerName.contains('缶') && !lowerName.contains('飲料')) ||
        lowerName.contains('canned')) {
      return '缶詰/加工食品';
    }

    // Beverages
    if (lowerName.contains('水') ||
        lowerName.contains('飲料') ||
        (lowerName.contains('缶') && lowerName.contains('飲料')) ||
        lowerName.contains('drink') ||
        lowerName.contains('water')) {
      return '飲料水/飲み物';
    }

    // Staple Foods
    if (lowerName.contains('米') ||
        lowerName.contains('ラーメン') ||
        lowerName.contains('乾パン') ||
        lowerName.contains('rice') ||
        lowerName.contains('noodle') ||
        lowerName.contains('ramen')) {
      return '主食類';
    }

    // Dairy Products
    if (lowerName.contains('牛乳') ||
        lowerName.contains('チーズ') ||
        lowerName.contains('milk') ||
        lowerName.contains('cheese')) {
      return '乳製品';
    }

    // Others (default)
    return 'その他';
  }
}
