import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/recipe.dart';
import '../../../fridge/domain/entities/fridge_item.dart';
import '../../../stock/domain/entities/stock_item.dart';

/// Firebase AI를 사용한 레시피 추천 데이터 소스
class RecipeAIDataSource {
  /// 현재 재고를 기반으로 GPT에게 레시피를 요청합니다.
  ///
  /// [fridgeItems]: 냉장고 재고 목록
  /// [stockItems]: 재고 목록
  /// [count]: 추천받을 레시피 개수
  ///
  /// 반환: 추천 레시피 목록
  Future<List<Recipe>> getRecipeRecommendations({
    required List<FridgeItem> fridgeItems,
    required List<StockItem> stockItems,
    required int count,
  }) async {
    try {
      // Firebase AI 초기화 (Gemini 2.0 Flash 사용)
      final model = FirebaseAI.googleAI().generativeModel(
        model: 'gemini-2.0-flash',
      );

      // 재고 목록을 문자열로 변환
      final inventoryText = _buildInventoryText(
        fridgeItems: fridgeItems,
        stockItems: stockItems,
      );

      // 프롬프트 생성
      final promptText =
          '''
以下の冷蔵庫とストックの在庫を使って、$count個のレシピを提案してください。

在庫リスト:
$inventoryText

【重要】基本調味料について:
以下の基本調味料は常に持っているものとして扱ってください。在庫リストに含まれていなくても、レシピに使用して構いません:
- 塩、砂糖、こしょう、醤油、みりん、酒、酢、油、バター、オリーブオイル、にんにく、生姜（基本的な調味料全般）

レシピ作成の注意事項:
1. 在庫リストにある材料を優先的に使用してください
2. 基本調味料は在庫リストに含まれていなくても使用可能です
3. 在庫リストにない特別な材料はできるだけ避けてください
4. 実用的で作りやすいレシピを提案してください

各レシピについて、以下の形式でJSON配列として返してください:
[
  {
    "title": "レシピ名",
    "description": "レシピの簡単な説明",
    "ingredients": ["材料1", "材料2", ...],
    "instructions": ["手順1", "手順2", ...],
    "cookingTime": 30,
    "servings": 2
  },
  ...
]

JSONのみを返してください。説明や追加のテキストは不要です。
''';

      final prompt = [Content.text(promptText)];
      final response = await model.generateContent(prompt);
      final text = response.text?.trim() ?? '';

      if (text.isEmpty) {
        debugPrint('AI応答が空です。');
        return [];
      }

      // JSON 파싱
      final recipes = _parseRecipesFromJson(text);
      debugPrint('レシピ 추천 성공: ${recipes.length}개');
      return recipes;
    } catch (e) {
      debugPrint('レシピ 추천 실패: $e');
      return [];
    }
  }

  /// 재고 목록을 텍스트로 변환합니다.
  String _buildInventoryText({
    required List<FridgeItem> fridgeItems,
    required List<StockItem> stockItems,
  }) {
    final buffer = StringBuffer();

    if (fridgeItems.isNotEmpty) {
      buffer.writeln('冷蔵庫:');
      for (final item in fridgeItems) {
        buffer.writeln(
          '  - ${item.name} (数量: ${item.quantity}${item.category != null ? ', カテゴリ: ${item.category}' : ''})',
        );
      }
    }

    if (stockItems.isNotEmpty) {
      if (fridgeItems.isNotEmpty) {
        buffer.writeln();
      }
      buffer.writeln('ストック:');
      for (final item in stockItems) {
        buffer.writeln(
          '  - ${item.name} (数量: ${item.quantity}${item.category != null ? ', カテゴリ: ${item.category}' : ''})',
        );
      }
    }

    return buffer.toString();
  }

  /// JSON 응답을 Recipe 리스트로 파싱합니다.
  List<Recipe> _parseRecipesFromJson(String jsonText) {
    try {
      // JSON 배열 부분만 추출 (```json 또는 ``` 제거)
      var cleanedText = jsonText.trim();

      // 마크다운 코드 블록 제거
      if (cleanedText.contains('```')) {
        final startIndex = cleanedText.indexOf('[');
        final endIndex = cleanedText.lastIndexOf(']');
        if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
          cleanedText = cleanedText.substring(startIndex, endIndex + 1);
        } else {
          // ```json ... ``` 형식 처리
          final lines = cleanedText.split('\n');
          cleanedText = lines
              .skipWhile((line) => line.trim().startsWith('```'))
              .takeWhile((line) => !line.trim().startsWith('```'))
              .join('\n')
              .trim();
        }
      }

      // JSON 파싱
      final decoded = jsonDecode(cleanedText);

      // 배열인지 확인
      if (decoded is! List) {
        debugPrint('JSON이 배열 형식이 아닙니다: $decoded');
        return [];
      }

      final json = decoded;
      return json
          .map((item) {
            if (item is! Map<String, dynamic>) {
              debugPrint('레시피 항목이 Map 형식이 아닙니다: $item');
              return null;
            }

            final map = item;
            return Recipe(
              title: map['title'] as String? ?? '',
              description: map['description'] as String? ?? '',
              ingredients:
                  (map['ingredients'] as List<dynamic>?)
                      ?.map((e) => e.toString())
                      .toList() ??
                  [],
              instructions:
                  (map['instructions'] as List<dynamic>?)
                      ?.map((e) => e.toString())
                      .toList() ??
                  [],
              cookingTime: map['cookingTime'] as int?,
              servings: map['servings'] as int?,
            );
          })
          .whereType<Recipe>()
          .toList();
    } catch (e) {
      debugPrint('JSON 파싱 실패: $e');
      debugPrint('원본 텍스트: $jsonText');
      return [];
    }
  }
}
