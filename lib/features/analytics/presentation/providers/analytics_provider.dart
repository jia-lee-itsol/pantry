import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/purchase_firestore_datasource.dart';
import '../../data/repositories_impl/purchase_repository_impl.dart';
import '../../domain/entities/purchase.dart';
import '../../domain/entities/spending_summary.dart';
import '../../domain/repositories/purchase_repository.dart';

/// Provider for the purchase Firestore data source.
///
/// Creates an instance of [PurchaseFirestoreDataSource] for data access.
final purchaseDataSourceProvider = Provider<PurchaseFirestoreDataSource>((ref) {
  return PurchaseFirestoreDataSource();
});

/// Provider for the purchase repository.
///
/// Exposes the [PurchaseRepository] interface with Firestore implementation.
final purchaseRepositoryProvider = Provider<PurchaseRepository>((ref) {
  final dataSource = ref.watch(purchaseDataSourceProvider);
  return PurchaseRepositoryImpl(dataSource);
});

/// Provider for all purchase records.
///
/// Fetches and returns all purchases for the current household,
/// automatically handling loading and error states.
final purchasesProvider = FutureProvider<List<Purchase>>((ref) async {
  final repository = ref.watch(purchaseRepositoryProvider);
  return repository.getPurchases();
});

/// Provider for overall spending summary.
///
/// Generates a complete spending summary including all purchases
/// without date filtering.
final spendingSummaryProvider = FutureProvider<SpendingSummary>((ref) async {
  final repository = ref.watch(purchaseRepositoryProvider);
  return repository.getSpendingSummary();
});

/// Provider for monthly spending aggregation.
///
/// Extracts monthly spending data from the overall spending summary
/// for display in charts and reports.
final monthlySpendingProvider = FutureProvider<Map<String, double>>((ref) async {
  final summary = await ref.watch(spendingSummaryProvider.future);
  return summary.monthlySpending;
});

/// Enumeration of available analytics time periods.
enum AnalyticsPeriod {
  /// Last 7 days
  week,

  /// Last 30 days
  month,

  /// Last 90 days
  threeMonths,

  /// Last 365 days
  year,
}

/// Notifier for managing selected analytics period state.
///
/// Allows users to filter analytics by different time periods.
class SelectedPeriodNotifier extends Notifier<AnalyticsPeriod> {
  /// Initializes with month as the default period.
  @override
  AnalyticsPeriod build() => AnalyticsPeriod.month;

  /// Updates the selected period.
  ///
  /// Parameters:
  ///   [period] - The new period to select
  void setPeriod(AnalyticsPeriod period) {
    state = period;
  }
}

/// Provider for the selected analytics period.
///
/// Manages the currently selected time period for filtering analytics data.
final selectedPeriodProvider =
    NotifierProvider<SelectedPeriodNotifier, AnalyticsPeriod>(
  () => SelectedPeriodNotifier(),
);

/// Provider for filtered spending summary based on selected period.
///
/// Generates a spending summary filtered by the currently selected time period.
/// Updates automatically when the period selection changes.
final filteredSpendingSummaryProvider = FutureProvider<SpendingSummary>((ref) async {
  final repository = ref.watch(purchaseRepositoryProvider);
  final period = ref.watch(selectedPeriodProvider);

  final now = DateTime.now();
  final DateTime startDate = switch (period) {
    AnalyticsPeriod.week => now.subtract(const Duration(days: 7)),
    AnalyticsPeriod.month => DateTime(now.year, now.month - 1, now.day),
    AnalyticsPeriod.threeMonths => DateTime(now.year, now.month - 3, now.day),
    AnalyticsPeriod.year => DateTime(now.year - 1, now.month, now.day),
  };

  return repository.getSpendingSummary(startDate: startDate, endDate: now);
});
