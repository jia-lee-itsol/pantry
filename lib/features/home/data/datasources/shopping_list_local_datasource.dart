import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shopping_list_item_model.dart';

// ============================================
// Shopping List Local Data Source
// ============================================

/// Local data source for shopping list items using SharedPreferences.
///
/// This class handles all local storage operations for shopping list items.
/// It uses SharedPreferences to persist data on the device and provides
/// default items when no data exists or when an error occurs.
///
/// Responsibilities:
/// - Load shopping list items from local storage
/// - Save shopping list items to local storage
/// - Provide default items for first-time users
/// - Handle serialization/deserialization errors gracefully
class ShoppingListLocalDataSource {
  /// Storage key for shopping list items in SharedPreferences
  static const String _key = 'shopping_list_items';

  /// Retrieves all shopping list items from local storage.
  ///
  /// This method attempts to load items from SharedPreferences. If no data
  /// exists or if an error occurs during loading, it returns default items.
  ///
  /// Returns a [Future] that completes with a list of [ShoppingListItemModel]s.
  ///
  /// Example:
  /// ```dart
  /// final dataSource = ShoppingListLocalDataSource();
  /// final items = await dataSource.getItems();
  /// ```
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
      // Return default items if SharedPreferences plugin is unavailable or parsing fails
      return _getDefaultItems();
    }
  }

  /// Saves a list of shopping list items to local storage.
  ///
  /// This method serializes the items to JSON and stores them in SharedPreferences.
  /// If saving fails, it throws an exception with error details.
  ///
  /// Parameters:
  /// - [items]: List of [ShoppingListItemModel]s to save
  ///
  /// Returns a [Future] that completes when saving is done.
  ///
  /// Throws an [Exception] if saving fails.
  ///
  /// Example:
  /// ```dart
  /// await dataSource.saveItems(itemsList);
  /// ```
  Future<void> saveItems(List<ShoppingListItemModel> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = items.map((item) => item.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await prefs.setString(_key, jsonString);
    } catch (e) {
      throw Exception('Failed to save shopping list: $e');
    }
  }

  /// Provides default shopping list items for first-time users.
  ///
  /// This private method returns a predefined list of sample items
  /// to demonstrate the app's functionality when no saved data exists.
  ///
  /// Returns a list of sample [ShoppingListItemModel]s.
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

