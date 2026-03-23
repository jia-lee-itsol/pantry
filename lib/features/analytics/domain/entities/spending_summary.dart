/// Domain entity representing aggregated spending analytics data.
///
/// This entity provides a comprehensive summary of spending patterns including
/// total spending, breakdown by category, daily spending trends, and date ranges.
class SpendingSummary {
  /// Total amount spent in the period
  final double totalSpending;

  /// Spending amounts grouped by category
  final Map<String, double> spendingByCategory;

  /// Daily spending amounts indexed by date
  final Map<DateTime, double> dailySpending;

  /// Total number of items purchased
  final int totalItems;

  /// Start date of the summary period
  final DateTime? startDate;

  /// End date of the summary period
  final DateTime? endDate;

  /// Creates a [SpendingSummary] instance.
  ///
  /// Required parameters: [totalSpending], [spendingByCategory],
  /// [dailySpending], and [totalItems].
  /// [startDate] and [endDate] are optional.
  const SpendingSummary({
    required this.totalSpending,
    required this.spendingByCategory,
    required this.dailySpending,
    required this.totalItems,
    this.startDate,
    this.endDate,
  });

  /// Creates an empty spending summary with zero values.
  ///
  /// Useful as a default value when no purchases exist.
  factory SpendingSummary.empty() {
    return const SpendingSummary(
      totalSpending: 0,
      spendingByCategory: {},
      dailySpending: {},
      totalItems: 0,
    );
  }

  /// Aggregates daily spending into monthly totals.
  ///
  /// Returns a map where keys are formatted as "YYYY-MM" and values
  /// are the total spending for that month.
  Map<String, double> get monthlySpending {
    final Map<String, double> monthly = {};
    for (final entry in dailySpending.entries) {
      final key = '${entry.key.year}-${entry.key.month.toString().padLeft(2, '0')}';
      monthly[key] = (monthly[key] ?? 0) + entry.value;
    }
    return monthly;
  }

  /// Returns the top 5 spending categories sorted by amount.
  ///
  /// Useful for displaying the most significant expense categories.
  List<MapEntry<String, double>> get topCategories {
    final sorted = spendingByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).toList();
  }
}
