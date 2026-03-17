import '../../domain/entities/purchase.dart';
import '../../domain/entities/spending_summary.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../datasources/purchase_firestore_datasource.dart';
import '../models/purchase_model.dart';

class PurchaseRepositoryImpl implements PurchaseRepository {
  final PurchaseFirestoreDataSource _dataSource;

  PurchaseRepositoryImpl(this._dataSource);

  @override
  Future<List<Purchase>> getPurchases() async {
    return await _dataSource.getPurchases();
  }

  @override
  Future<List<Purchase>> getPurchasesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    return await _dataSource.getPurchasesByDateRange(start, end);
  }

  @override
  Future<void> addPurchase(Purchase purchase) async {
    await _dataSource.addPurchase(PurchaseModel.fromEntity(purchase));
  }

  @override
  Future<void> addPurchases(List<Purchase> purchases) async {
    final models = purchases.map((p) => PurchaseModel.fromEntity(p)).toList();
    await _dataSource.addPurchases(models);
  }

  @override
  Future<void> deletePurchase(String id) async {
    await _dataSource.deletePurchase(id);
  }

  @override
  Future<SpendingSummary> getSpendingSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final now = DateTime.now();
    final start = startDate ?? DateTime(now.year, now.month - 11, 1);
    final end = endDate ?? now;

    final purchases = await getPurchasesByDateRange(start, end);

    if (purchases.isEmpty) {
      return SpendingSummary.empty();
    }

    double totalSpending = 0;
    final Map<String, double> spendingByCategory = {};
    final Map<DateTime, double> dailySpending = {};

    for (final purchase in purchases) {
      final total = purchase.totalPrice;
      totalSpending += total;

      // Category spending
      final category = purchase.category ?? 'その他';
      spendingByCategory[category] = (spendingByCategory[category] ?? 0) + total;

      // Daily spending
      final date = DateTime(
        purchase.purchaseDate.year,
        purchase.purchaseDate.month,
        purchase.purchaseDate.day,
      );
      dailySpending[date] = (dailySpending[date] ?? 0) + total;
    }

    return SpendingSummary(
      totalSpending: totalSpending,
      spendingByCategory: spendingByCategory,
      dailySpending: dailySpending,
      totalItems: purchases.length,
      startDate: start,
      endDate: end,
    );
  }
}
