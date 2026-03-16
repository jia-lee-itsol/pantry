import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/usecases/check_low_stock_usecase.dart';
import '../domain/usecases/check_expiry_usecase.dart';

// Core Business Logic Use Case Providers
final checkLowStockUseCaseProvider = Provider<CheckLowStockUseCase>((ref) {
  return CheckLowStockUseCase();
});

final checkExpiryUseCaseProvider = Provider<CheckExpiryUseCase>((ref) {
  return CheckExpiryUseCase();
});
