import '../entities/fridge_item.dart';

/// Use Case for filtering items that are near expiry.
/// Contains business rule: items expiring within specified days.
class GetNearExpiryItemsUseCase {
  static const int defaultNearExpiryDays = 7;

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

  /// Check if a single item is near expiry.
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
