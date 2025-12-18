import '../entities/stock_item.dart';
import '../repositories/stock_repository.dart';

class GetStockItemsUseCase {
  final StockRepository repository;

  GetStockItemsUseCase(this.repository);

  Future<List<StockItem>> call() {
    return repository.getStockItems();
  }
}

