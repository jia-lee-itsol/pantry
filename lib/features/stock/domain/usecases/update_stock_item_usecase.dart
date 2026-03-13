import '../entities/stock_item.dart';
import '../repositories/stock_repository.dart';

class UpdateStockItemUseCase {
  final StockRepository repository;

  UpdateStockItemUseCase(this.repository);

  Future<void> call(StockItem item) {
    return repository.updateStockItem(item);
  }
}
