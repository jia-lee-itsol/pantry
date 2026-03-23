/// Application Keys
///
/// Defines key strings used for data storage and retrieval.
/// This includes both local storage keys (SharedPreferences)
/// and Firestore collection names.
///
/// Centralizing these keys helps prevent typos and makes it
/// easier to maintain data structure consistency.
///
/// All values are static and the constructor is private to prevent instantiation.
class AppKeys {
  AppKeys._();

  // ============================================================
  // SECTION: Local Storage Keys (SharedPreferences)
  // ============================================================
  static const String fridgeItems = 'fridge_items';
  static const String stockItems = 'stock_items';
  static const String alerts = 'alerts';
  static const String userPreferences = 'user_preferences';

  // ============================================================
  // SECTION: Firestore Collection Names
  // ============================================================
  static const String fridgeCollection = 'fridge_items';
  static const String stockCollection = 'stock_items';
  static const String alertsCollection = 'alerts';
  static const String receiptsCollection = 'receipts';
  static const String purchasesCollection = 'purchases';
}

