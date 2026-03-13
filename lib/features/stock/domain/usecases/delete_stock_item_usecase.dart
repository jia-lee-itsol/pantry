import '../repositories/stock_repository.dart';

class DeleteStockItemUseCase {
  final StockRepository repository;

  DeleteStockItemUseCase(this.repository);

  Future<void> call(String id) {
    return repository.deleteStockItem(id);
  }
}
