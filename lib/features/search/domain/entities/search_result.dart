/// Enum representing the source of a search result.
enum SearchResultSource {
  fridge,
  stock,
}

/// Entity representing a unified search result from fridge or stock items.
class SearchResult {
  final String id;
  final String name;
  final int quantity;
  final String? category;
  final DateTime? expiryDate;
  final SearchResultSource source;
  final bool? isFrozen; // Only for fridge items
  final int? targetQuantity;

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

  String get sourceLabel => source == SearchResultSource.fridge ? '冷蔵庫' : '備蓄品';

  bool get isLowStock {
    final threshold = targetQuantity ?? 5;
    return quantity < threshold;
  }

  bool get isNearExpiry {
    if (expiryDate == null) return false;
    final now = DateTime.now();
    final days = expiryDate!.difference(now).inDays;
    return days >= 0 && days <= 7;
  }

  bool get isExpired {
    if (expiryDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate!.year, expiryDate!.month, expiryDate!.day);
    return expiry.isBefore(today);
  }
}
