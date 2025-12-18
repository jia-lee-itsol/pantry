import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category_model.dart';

class CategoryLocalDataSource {
  static const String _key = 'categories';

  Future<List<CategoryModel>> getCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_key);
      if (jsonString == null) {
        return _getDefaultCategories();
      }
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
    } catch (e) {
      // shared_preferences 플러그인이 사용 불가능한 경우 기본 카테고리 반환
      // MissingPluginException 등은 기본 카테고리를 반환하여 앱이 계속 작동하도록 함
      return _getDefaultCategories();
    }
  }

  Future<void> saveCategories(List<CategoryModel> categories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = categories.map((c) => c.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await prefs.setString(_key, jsonString);
    } catch (e) {
      // shared_preferences 플러그인이 사용 불가능한 경우 에러를 다시 throw
      // (예: 웹에서 실행 중이거나 플러그인이 제대로 등록되지 않은 경우)
      throw Exception('カテゴリ保存失敗: $e');
    }
  }

  List<CategoryModel> _getDefaultCategories() {
    final now = DateTime.now();
    return [
      CategoryModel(
        id: '1',
        name: '果物',
        iconName: 'apple',
        order: 1,
        createdAt: now,
      ),
      CategoryModel(
        id: '2',
        name: 'タンパク質',
        iconName: 'egg',
        order: 2,
        createdAt: now,
      ),
      CategoryModel(
        id: '3',
        name: '乳製品',
        iconName: 'local_drink',
        order: 3,
        createdAt: now,
      ),
      CategoryModel(
        id: '4',
        name: '野菜',
        iconName: 'eco',
        order: 4,
        createdAt: now,
      ),
      CategoryModel(
        id: '5',
        name: '冷凍食品',
        iconName: 'ac_unit',
        order: 5,
        createdAt: now,
      ),
      CategoryModel(
        id: '6',
        name: '飲料水/飲み物',
        iconName: 'water_drop',
        order: 6,
        createdAt: now,
      ),
      CategoryModel(
        id: '7',
        name: '主食類',
        iconName: 'rice_bowl',
        order: 7,
        createdAt: now,
      ),
      CategoryModel(
        id: '8',
        name: '缶詰/加工食品',
        iconName: 'inventory_2',
        order: 8,
        createdAt: now,
      ),
      CategoryModel(
        id: '9',
        name: 'その他',
        iconName: 'category',
        order: 9,
        createdAt: now,
      ),
    ];
  }
}
