/// Application Strings
///
/// Defines all user-facing text strings used in the application.
/// Centralized string management makes it easier to maintain
/// consistency and prepare for future localization.
///
/// Note: Currently using Japanese strings. This can be converted
/// to a proper localization system (e.g., Flutter l10n) in the future.
///
/// All values are static and the constructor is private to prevent instantiation.
class AppStrings {
  AppStrings._();

  // ============================================================
  // SECTION: App Info
  // ============================================================
  static const String appName = 'Pantry';
  static const String appVersion = '0.1.0';

  // ============================================================
  // SECTION: Navigation
  // ============================================================
  static const String home = 'ホーム';
  static const String fridge = '冷蔵庫';
  static const String stock = '備蓄品';
  static const String ocr = 'OCR';
  static const String map = 'マップ';
  static const String settings = '設定';

  // ============================================================
  // SECTION: Fridge
  // ============================================================
  static const String fridgeList = '冷蔵庫の在庫';
  static const String addFridgeItem = '在庫追加';

  // ============================================================
  // SECTION: Stock
  // ============================================================
  static const String stockList = '災害備蓄品';
  static const String addStockItem = '備蓄品追加';

  // ============================================================
  // SECTION: OCR
  // ============================================================
  static const String receiptScan = 'レシートスキャン';
  static const String scanReceipt = 'レシートをスキャンしてください';

  // ============================================================
  // SECTION: Map
  // ============================================================
  static const String shelterMap = '避難所マップ';
  static const String nearbyShelters = '近くの避難所';

  // ============================================================
  // SECTION: Alerts
  // ============================================================
  static const String alerts = '通知';
  static const String expiryAlert = '賞味期限通知';
  static const String stockAlert = '備蓄品通知';

  // ============================================================
  // SECTION: Common
  // ============================================================
  static const String loading = '読み込み中...';
  static const String error = 'エラーが発生しました';
  static const String retry = '再試行';
  static const String save = '保存';
  static const String cancel = 'キャンセル';
  static const String delete = '削除';
  static const String edit = '編集';
}

