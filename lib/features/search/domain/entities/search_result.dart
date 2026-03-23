/// Enumeration representing the source location of a search result.
enum SearchResultSource {
  /// Item is from the fridge
  fridge,

  /// Item is from the stock/pantry
  stock,
}

/// Domain entity representing a unified search result from fridge or stock.
///
/// This entity combines items from different sources (fridge and stock) into
/// a single searchable format, including computed properties for stock status
/// and expiry information.
class SearchResult {
  /// Unique identifier for the item
  final String id;

  /// Name of the item
  final String name;

  /// Current quantity of the item
  final int quantity;

  /// Category the item belongs to
  final String? category;

  /// Expiration date of the item (if applicable)
  final DateTime? expiryDate;

  /// Source location of the item (fridge or stock)
  final SearchResultSource source;

  /// Whether the item is frozen (only applicable for fridge items)
  final bool? isFrozen;

  /// Target quantity threshold for low stock alerts
  final int? targetQuantity;

  /// Creates a [SearchResult] instance.
  ///
  /// Required parameters: [id], [name], [quantity], and [source].
  /// Optional parameters provide additional context about the item.
  const SearchResult({
    required this.id,
    required this.name,
    required this.quantity,
    this.category,
    this.expiryDate,
    required this.source,
    this.isFrozen,
    this.targetQuantity,
  });

  /// Returns a localized label for the source (e.g., "Fridge" or "Stock").
  String get sourceLabel => source == SearchResultSource.fridge ? '冷蔵庫' : '備蓄品';

  /// Checks if the item quantity is below the target threshold.
  ///
  /// Returns true if quantity is less than targetQuantity (default: 5).
  bool get isLowStock {
    final threshold = targetQuantity ?? 5;
    return quantity < threshold;
  }

  /// Checks if the item is nearing expiration (within 7 days).
  ///
  /// Returns true if the item expires within 7 days and is not yet expired.
  bool get isNearExpiry {
    if (expiryDate == null) return false;
    final now = DateTime.now();
    final days = expiryDate!.difference(now).inDays;
    return days >= 0 && days <= 7;
  }

  /// Checks if the item has already expired.
  ///
  /// Returns true if the expiry date is before today's date.
  bool get isExpired {
    if (expiryDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate!.year, expiryDate!.month, expiryDate!.day);
    return expiry.isBefore(today);
  }
}
