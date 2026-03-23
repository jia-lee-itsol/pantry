import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/ocr/domain/repositories/ocr_repository.dart';
import '../../features/ocr/data/datasources/ocr_google_vision_datasource.dart';
import '../../features/ocr/data/repositories_impl/ocr_repository_impl.dart';
import 'fridge_service.dart';

/// OCR Service Provider
///
/// Provides the OCR (Optical Character Recognition) repository implementation
/// using dependency injection. This provider creates and manages the OCR data source
/// and repository for extracting text from images throughout the application.
///
/// The repository uses Google Vision API as the data source for text recognition
/// and integrates with the fridge repository for processing scanned receipt items.
final ocrServiceProvider = Provider<OCRRepository>((ref) {
  final dataSource = OCRGoogleVisionDataSource();
  final fridgeRepository = ref.watch(fridgeServiceProvider);
  return OCRRepositoryImpl(dataSource, fridgeRepository);
});

