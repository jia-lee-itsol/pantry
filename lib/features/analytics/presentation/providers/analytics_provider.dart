import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/purchase_firestore_datasource.dart';
import '../../data/repositories_impl/purchase_repository_impl.dart';
import '../../domain/entities/purchase.dart';
import '../../domain/entities/spending_summary.dart';
import '../../domain/repositories/purchase_repository.dart';

// Data Source Provider
final purchaseDataSourceProvider = Provider<PurchaseFirestoreDataSource>((ref) {
  return PurchaseFirestoreDataSource();
});

// Repository Provider
final purchaseRepositoryProvider = Provider<PurchaseRepository>((ref) {
  final dataSource = ref.watch(purchaseDataSourceProvider);
  return PurchaseRepositoryImpl(dataSource);
});

// Purchases Provider
final purchasesProvider = FutureProvider<List<Purchase>>((ref) async {
  final repository = ref.watch(purchaseRepositoryProvider);
  return repository.getPurchases();
});

// Spending Summary Provider
final spendingSummaryProvider = FutureProvider<SpendingSummary>((ref) async {
  final repository = ref.watch(purchaseRepositoryProvider);
  return repository.getSpendingSummary();
});

// Monthly Spending Summary Provider (last 6 months)
final monthlySpendingProvider = FutureProvider<Map<String, double>>((ref) async {
  final summary = await ref.watch(spendingSummaryProvider.future);
  return summary.monthlySpending;
});

// Selected Period Provider for filtering
enum AnalyticsPeriod {
  week,
  month,
  threeMonths,
  year,
}

class SelectedPeriodNotifier extends Notifier<AnalyticsPeriod> {
  @override
  AnalyticsPeriod build() => AnalyticsPeriod.month;

  void setPeriod(AnalyticsPeriod period) {
    state = period;
  }
}

final selectedPeriodProvider =
    NotifierProvider<SelectedPeriodNotifier, AnalyticsPeriod>(
  () => SelectedPeriodNotifier(),
);

// Filtered Spending Summary based on selected period
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
