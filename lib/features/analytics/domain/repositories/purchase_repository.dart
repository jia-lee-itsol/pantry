import '../entities/purchase.dart';
import '../entities/spending_summary.dart';

/// Repository interface for purchase and spending analytics operations.
///
/// This repository defines the contract for managing purchase records and
/// generating spending analytics summaries.
abstract class PurchaseRepository {
  /// Retrieves all purchase records.
  ///
  /// Returns a list of [Purchase] objects ordered by purchase date (newest first).
  /// Throws an exception if the operation fails.
  Future<List<Purchase>> getPurchases();

  /// Retrieves purchases within a specific date range.
  ///
  /// Parameters:
  ///   [start] - Start date of the range (inclusive)
  ///   [end] - End date of the range (inclusive)
  ///
  /// Returns a list of [Purchase] objects within the date range.
  /// Throws an exception if the operation fails.
  Future<List<Purchase>> getPurchasesByDateRange(DateTime start, DateTime end);

  /// Adds a single purchase record.
  ///
  /// Parameters:
  ///   [purchase] - The purchase to add
  ///
  /// Throws an exception if the operation fails.
  Future<void> addPurchase(Purchase purchase);

  /// Adds multiple purchase records in batch.
  ///
  /// Parameters:
  ///   [purchases] - The list of purchases to add
  ///
  /// Throws an exception if the operation fails.
  Future<void> addPurchases(List<Purchase> purchases);

  /// Deletes a purchase record.
  ///
  /// Parameters:
  ///   [id] - The unique identifier of the purchase to delete
  ///
  /// Throws an exception if the operation fails.
  Future<void> deletePurchase(String id);

  /// Generates a spending summary for a given period.
  ///
  /// Parameters:
  ///   [startDate] - Optional start date for the summary period
  ///   [endDate] - Optional end date for the summary period
  ///
  /// Returns a [SpendingSummary] with aggregated spending data.
  /// If no dates are provided, summarizes all purchases.
  /// Throws an exception if the operation fails.
  Future<SpendingSummary> getSpendingSummary({DateTime? startDate, DateTime? endDate});
}
