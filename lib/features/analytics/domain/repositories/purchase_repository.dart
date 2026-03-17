import '../entities/purchase.dart';
import '../entities/spending_summary.dart';

abstract class PurchaseRepository {
  Future<List<Purchase>> getPurchases();
  Future<List<Purchase>> getPurchasesByDateRange(DateTime start, DateTime end);
  Future<void> addPurchase(Purchase purchase);
  Future<void> addPurchases(List<Purchase> purchases);
  Future<void> deletePurchase(String id);
  Future<SpendingSummary> getSpendingSummary({DateTime? startDate, DateTime? endDate});
}
