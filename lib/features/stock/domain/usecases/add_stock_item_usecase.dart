import '../entities/stock_item.dart';
import '../repositories/stock_repository.dart';

class AddStockItemUseCase {
  final StockRepository repository;

  AddStockItemUseCase(this.repository);

  Future<void> call(StockItem item) {
    return repository.addStockItem(item);
  }
}
