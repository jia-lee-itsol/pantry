import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shopping_list_item_model.dart';

class ShoppingListLocalDataSource {
  static const String _key = 'shopping_list_items';

  Future<List<ShoppingListItemModel>> getItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_key);
      if (jsonString == null) {
        return _getDefaultItems();
      }
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => ShoppingListItemModel.fromJson(
              json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // shared_preferences 플러그인이 사용 불가능한 경우 기본 항목 반환
      return _getDefaultItems();
    }
  }

  Future<void> saveItems(List<ShoppingListItemModel> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = items.map((item) => item.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await prefs.setString(_key, jsonString);
    } catch (e) {
      throw Exception('ショッピングリスト保存失敗: $e');
    }
  }

  List<ShoppingListItemModel> _getDefaultItems() {
    return [
      const ShoppingListItemModel(
        id: '1',
        name: '牛乳',
        estimatedPrice: 250,
        isCompleted: false,
        category: 'fridge',
      ),
      const ShoppingListItemModel(
        id: '2',
        name: '卵',
        estimatedPrice: 200,
        isCompleted: false,
        category: 'fridge',
      ),
      const ShoppingListItemModel(
        id: '3',
        name: 'レタス',
        estimatedPrice: 150,
        isCompleted: false,
        category: 'fridge',
      ),
      const ShoppingListItemModel(
        id: '4',
        name: '鶏むね肉',
        estimatedPrice: 500,
        isCompleted: false,
        category: 'fridge',
      ),
      const ShoppingListItemModel(
        id: '5',
        name: '豆腐',
        estimatedPrice: 100,
        isCompleted: true,
        category: 'fridge',
      ),
    ];
  }
}

