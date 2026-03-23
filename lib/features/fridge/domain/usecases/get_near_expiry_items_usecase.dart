import '../entities/fridge_item.dart';

/// Use case for filtering items that are near their expiration date.
///
/// This use case implements the business rule for identifying food items
/// that should be consumed soon to minimize waste.
///
/// ## Business Rules:
/// - Default threshold: 7 days until expiry
/// - Only includes items that haven't expired yet (>= 0 days remaining)
/// - Date comparison uses day-level precision (ignores time)
///
/// ## Usage:
/// ```dart
/// final useCase = GetNearExpiryItemsUseCase();
///
/// // Get items expiring in next 7 days (default)
/// final soonToExpire = useCase(allItems);
///
/// // Get items expiring in next 3 days (custom threshold)
/// final urgent = useCase(allItems, nearExpiryDays: 3);
///
/// // Check a single item
/// if (useCase.isNearExpiry(milk)) {
///   print('Drink the milk soon!');
/// }
/// ```
class GetNearExpiryItemsUseCase {
  /// Default threshold in days for "near expiry" classification
  static const int defaultNearExpiryDays = 7;

  /// Filters items that are near their expiration date.
  ///
  /// Parameters:
  /// - [items]: The list of fridge items to filter
  /// - [nearExpiryDays]: Number of days threshold (default: 7)
  ///
  /// Returns items where:
  /// - 0 <= days until expiry <= nearExpiryDays
  ///
  /// Example: With nearExpiryDays=7, includes items expiring
  /// today through 7 days from now.
  List<FridgeItem> call(
    List<FridgeItem> items, {
    int nearExpiryDays = defaultNearExpiryDays,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return items.where((item) {
      final expiryDate = DateTime(
        item.expiryDate.year,
        item.expiryDate.month,
        item.expiryDate.day,
      );
      final daysUntilExpiry = expiryDate.difference(today).inDays;
      return daysUntilExpiry <= nearExpiryDays && daysUntilExpiry >= 0;
    }).toList();
  }

  /// Checks if a single item is near expiry.
  ///
  /// Parameters:
  /// - [item]: The fridge item to check
  /// - [nearExpiryDays]: Number of days threshold (default: 7)
  ///
  /// Returns `true` if the item expires within the threshold and hasn't expired yet.
  bool isNearExpiry(FridgeItem item, {int nearExpiryDays = defaultNearExpiryDays}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiryDate = DateTime(
      item.expiryDate.year,
      item.expiryDate.month,
      item.expiryDate.day,
    );
    final daysUntilExpiry = expiryDate.difference(today).inDays;
    return daysUntilExpiry <= nearExpiryDays && daysUntilExpiry >= 0;
  }
}
