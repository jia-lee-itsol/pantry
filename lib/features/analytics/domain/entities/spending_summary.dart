/// Entity representing spending summary for analytics.
class SpendingSummary {
  final double totalSpending;
  final Map<String, double> spendingByCategory;
  final Map<DateTime, double> dailySpending;
  final int totalItems;
  final DateTime? startDate;
  final DateTime? endDate;

  const SpendingSummary({
    required this.totalSpending,
    required this.spendingByCategory,
    required this.dailySpending,
    required this.totalItems,
    this.startDate,
    this.endDate,
  });

  factory SpendingSummary.empty() {
    return const SpendingSummary(
      totalSpending: 0,
      spendingByCategory: {},
      dailySpending: {},
      totalItems: 0,
    );
  }

  /// Get monthly spending from daily spending data.
  Map<String, double> get monthlySpending {
    final Map<String, double> monthly = {};
    for (final entry in dailySpending.entries) {
      final key = '${entry.key.year}-${entry.key.month.toString().padLeft(2, '0')}';
      monthly[key] = (monthly[key] ?? 0) + entry.value;
    }
    return monthly;
  }

  /// Get top spending categories.
  List<MapEntry<String, double>> get topCategories {
    final sorted = spendingByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).toList();
  }
}
