import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/usecases/check_low_stock_usecase.dart';
import '../domain/usecases/check_expiry_usecase.dart';

/// Core Business Logic Use Case Providers
///
/// Provides use case instances that encapsulate core business logic
/// for the application. Use cases are stateless and can be shared
/// across the application.

/// Check Low Stock Use Case Provider
///
/// Provides the use case for determining if items are low on stock.
final checkLowStockUseCaseProvider = Provider<CheckLowStockUseCase>((ref) {
  return CheckLowStockUseCase();
});

/// Check Expiry Use Case Provider
///
/// Provides the use case for checking expiry-related business rules.
final checkExpiryUseCaseProvider = Provider<CheckExpiryUseCase>((ref) {
  return CheckExpiryUseCase();
});
