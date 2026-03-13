import '../entities/shopping_list_item.dart';

/// 쇼핑 리스트 데이터 접근을 위한 Repository 인터페이스
abstract class ShoppingListRepository {
  /// 모든 쇼핑 리스트 아이템을 가져옴
  Future<List<ShoppingListItem>> getItems();

  /// 새 아이템 추가
  Future<void> addItem(ShoppingListItem item);

  /// 아이템 업데이트
  Future<void> updateItem(ShoppingListItem item);

  /// 아이템 삭제
  Future<void> deleteItem(String id);

  /// 모든 아이템 저장 (전체 리스트 교체)
  Future<void> saveItems(List<ShoppingListItem> items);
}
