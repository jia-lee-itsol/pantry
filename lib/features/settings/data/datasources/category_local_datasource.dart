import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category_model.dart';

/// Local data source for category storage using SharedPreferences.
///
/// This class manages category data persistence in local storage,
/// including loading, saving, and providing default categories
/// when no custom categories exist.
class CategoryLocalDataSource {
  static const String _key = 'categories';

  /// Retrieves categories from local storage.
  ///
  /// Returns saved categories if they exist, otherwise returns default categories.
  /// Categories are automatically sorted by their order property.
  ///
  /// Returns a list of [CategoryModel] objects.
  /// If SharedPreferences is unavailable, returns default categories.
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
      // Return default categories if SharedPreferences is unavailable
      // (e.g., MissingPluginException) to keep the app functional
      return _getDefaultCategories();
    }
  }

  /// Saves categories to local storage.
  ///
  /// Serializes the category list to JSON and stores it in SharedPreferences.
  ///
  /// Parameters:
  ///   [categories] - The list of categories to save
  ///
  /// Throws an exception if SharedPreferences is unavailable or saving fails.
  Future<void> saveCategories(List<CategoryModel> categories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = categories.map((c) => c.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await prefs.setString(_key, jsonString);
    } catch (e) {
      // Re-throw exception if SharedPreferences is unavailable
      // (e.g., running on web or plugin not properly registered)
      throw Exception('Failed to save categories: $e');
    }
  }

  /// Provides a set of default categories.
  ///
  /// These categories are used when no custom categories exist or
  /// when local storage is unavailable.
  ///
  /// Returns a list of predefined [CategoryModel] objects including
  /// common food categories like fruits, proteins, dairy, vegetables, etc.
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
