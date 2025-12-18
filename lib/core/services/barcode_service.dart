import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/barcode/domain/repositories/barcode_repository.dart';
import '../../features/barcode/data/datasources/barcode_mlkit_datasource.dart';
import '../../features/barcode/data/repositories_impl/barcode_repository_impl.dart';

/// 바코드 서비스 프로바이더
final barcodeServiceProvider = Provider<BarcodeRepository>((ref) {
  final dataSource = BarcodeMLKitDataSource();
  return BarcodeRepositoryImpl(dataSource);
});

