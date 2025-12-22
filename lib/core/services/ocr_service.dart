import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/ocr/domain/repositories/ocr_repository.dart';
import '../../features/ocr/data/datasources/ocr_google_vision_datasource.dart';
import '../../features/ocr/data/repositories_impl/ocr_repository_impl.dart';
import 'fridge_service.dart';

final ocrServiceProvider = Provider<OCRRepository>((ref) {
  final dataSource = OCRGoogleVisionDataSource();
  final fridgeRepository = ref.watch(fridgeServiceProvider);
  return OCRRepositoryImpl(dataSource, fridgeRepository);
});

