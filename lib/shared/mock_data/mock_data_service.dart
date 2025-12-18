import '../../features/fridge/data/models/fridge_item_model.dart';
import '../../features/stock/data/models/stock_item_model.dart';

class MockDataService {
  MockDataService._();

  static List<FridgeItemModel> getMockFridgeItems() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return [
      // 오늘 만료
      FridgeItemModel(
        id: '1',
        name: '牛乳',
        quantity: 1,
        category: '乳製品',
        expiryDate: today,
        createdAt: today.subtract(const Duration(days: 3)),
      ),
      FridgeItemModel(
        id: '2',
        name: '豆腐',
        quantity: 2,
        category: 'その他',
        expiryDate: today,
        createdAt: today.subtract(const Duration(days: 2)),
      ),
      // 내일 만료
      FridgeItemModel(
        id: '3',
        name: 'ヨーグルト',
        quantity: 4,
        category: '乳製品',
        expiryDate: today.add(const Duration(days: 1)),
        createdAt: today.subtract(const Duration(days: 1)),
        isFrozen: true, // 냉동 처리됨
      ),
      // 며칠 후 만료
      FridgeItemModel(
        id: '4',
        name: '卵',
        quantity: 12,
        category: 'タンパク質',
        expiryDate: today.add(const Duration(days: 3)),
        createdAt: today.subtract(const Duration(days: 5)),
        isFrozen: true, // 냉동 처리됨
      ),
      FridgeItemModel(
        id: '5',
        name: 'りんご',
        quantity: 5,
        category: '果物',
        expiryDate: today.add(const Duration(days: 5)),
        createdAt: today.subtract(const Duration(days: 2)),
      ),
      FridgeItemModel(
        id: '6',
        name: 'にんじん',
        quantity: 3,
        category: '野菜',
        expiryDate: today.add(const Duration(days: 7)),
        createdAt: today.subtract(const Duration(days: 1)),
      ),
      // 안전한 날짜
      FridgeItemModel(
        id: '7',
        name: 'チーズ',
        quantity: 1,
        category: '乳製品',
        expiryDate: today.add(const Duration(days: 15)),
        createdAt: today.subtract(const Duration(days: 2)),
      ),
      FridgeItemModel(
        id: '8',
        name: 'レタス',
        quantity: 1,
        category: '野菜',
        expiryDate: today.add(const Duration(days: 10)),
        createdAt: today.subtract(const Duration(days: 1)),
      ),
    ];
  }

  static List<StockItemModel> getMockStockItems() {
    final now = DateTime.now();

    return [
      StockItemModel(
        id: '1',
        name: 'ラーメン',
        quantity: 12,
        lastUpdated: now.subtract(const Duration(days: 5)),
      ),
      StockItemModel(
        id: '2',
        name: '米',
        quantity: 2,
        lastUpdated: now.subtract(const Duration(days: 10)),
      ),
      StockItemModel(
        id: '3',
        name: '水',
        quantity: 24,
        lastUpdated: now.subtract(const Duration(days: 3)),
      ),
      StockItemModel(
        id: '4',
        name: '缶詰',
        quantity: 8,
        lastUpdated: now.subtract(const Duration(days: 7)),
      ),
      StockItemModel(
        id: '5',
        name: '缶飲料',
        quantity: 20,
        lastUpdated: now.subtract(const Duration(days: 2)),
      ),
      StockItemModel(
        id: '6',
        name: '乾パン',
        quantity: 5,
        lastUpdated: now.subtract(const Duration(days: 15)),
      ),
      StockItemModel(
        id: '7',
        name: 'お菓子',
        quantity: 10,
        lastUpdated: now.subtract(const Duration(days: 1)),
      ),
      StockItemModel(
        id: '8',
        name: '牛乳',
        quantity: 6,
        lastUpdated: now.subtract(const Duration(days: 4)),
      ),
      StockItemModel(
        id: '9',
        name: '卵',
        quantity: 30,
        lastUpdated: now.subtract(const Duration(days: 6)),
      ),
      StockItemModel(
        id: '10',
        name: 'ハム',
        quantity: 5,
        lastUpdated: now.subtract(const Duration(days: 3)),
      ),
      StockItemModel(
        id: '11',
        name: 'チーズ',
        quantity: 3,
        lastUpdated: now.subtract(const Duration(days: 8)),
      ),
      StockItemModel(
        id: '12',
        name: 'パン',
        quantity: 4,
        lastUpdated: now.subtract(const Duration(days: 2)),
      ),
    ];
  }
}
