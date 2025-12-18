import 'dart:io';

import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:flutter/foundation.dart';

/// ML Kit을 사용한 바코드 스캔 데이터 소스
class BarcodeMLKitDataSource {
  final BarcodeScanner _barcodeScanner;

  BarcodeMLKitDataSource()
      : _barcodeScanner = BarcodeScanner(formats: [
          BarcodeFormat.all,
        ]);

  /// 이미지에서 바코드를 스캔합니다.
  ///
  /// [imagePath]: 스캔할 이미지 경로
  ///
  /// 반환: 바코드 값 (EAN-13, EAN-8, UPC-A, UPC-E 등)
  Future<String?> scanBarcode(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final List<Barcode> barcodes =
          await _barcodeScanner.processImage(inputImage);

      if (barcodes.isEmpty) {
        debugPrint('바코드를 찾을 수 없습니다.');
        return null;
      }

      // 첫 번째 바코드 반환
      final barcode = barcodes.first;
      final barcodeValue = barcode.displayValue ?? barcode.rawValue;

      if (barcodeValue == null || barcodeValue.isEmpty) {
        debugPrint('바코드 값이 비어있습니다.');
        return null;
      }

      debugPrint('바코드 스캔 성공: $barcodeValue');
      return barcodeValue;
    } catch (e) {
      debugPrint('바코드 스캔 실패: $e');
      rethrow;
    }
  }

  /// 리소스 정리
  void dispose() {
    _barcodeScanner.close();
  }
}

