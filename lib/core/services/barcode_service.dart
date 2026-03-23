import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/barcode/domain/repositories/barcode_repository.dart';
import '../../features/barcode/data/datasources/barcode_mlkit_datasource.dart';
import '../../features/barcode/data/repositories_impl/barcode_repository_impl.dart';

/// Barcode Service Provider
///
/// Provides the barcode repository implementation using dependency injection.
/// This provider creates and manages the barcode scanning data source and repository
/// for handling barcode recognition throughout the application.
///
/// The repository uses Google ML Kit as the data source for barcode scanning
/// and product information retrieval.
final barcodeServiceProvider = Provider<BarcodeRepository>((ref) {
  final dataSource = BarcodeMLKitDataSource();
  return BarcodeRepositoryImpl(dataSource);
});

