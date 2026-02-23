import 'package:equatable/equatable.dart';

import './product.dart';

class StockChange extends Equatable {
  const StockChange({
    required this.store,
    required this.quantity,
    required this.stockUpdated,
    this.stockedAt,
    this.unstockedAt,
    this.stockUnstockAt,
    required this.product,
  });

  factory StockChange.fromJson(Map<String, dynamic> stockChange) => StockChange(
        store: stockChange['store'].toString(),
        quantity: stockChange['quantity'],
        stockUpdated: DateTime.parse(stockChange['stock_updated']),
        stockedAt: stockChange['stocked_at'] != null
            ? DateTime.parse(stockChange['stocked_at'].split("+")[0])
            : null,
        unstockedAt: stockChange['unstocked_at'] != null
            ? DateTime.parse(stockChange['unstocked_at'].split("+")[0])
            : null,
        product: Product.fromJson(stockChange['beer']),
        stockUnstockAt:
            stockChange['quantity'] > 0 && stockChange['stocked_at'] != null
                ? DateTime.parse(stockChange['stocked_at'].split("+")[0])
                : stockChange['unstocked_at'] != null
                    ? DateTime.parse(stockChange['unstocked_at'].split("+")[0])
                    : null,
      );

  @override
  List<Object?> get props => [
        store,
        quantity,
        stockUpdated,
        stockedAt,
        unstockedAt,
        stockUnstockAt,
        product,
      ];

  final String store;
  final int quantity;
  final DateTime stockUpdated;
  final DateTime? stockedAt;
  final DateTime? unstockedAt;
  final DateTime? stockUnstockAt;
  final Product product;

  StockChange copyWith({Product? product}) => StockChange(
        store: store,
        quantity: quantity,
        stockUpdated: stockUpdated,
        stockedAt: stockedAt,
        unstockedAt: unstockedAt,
        stockUnstockAt: stockUnstockAt,
        product: product ?? this.product,
      );
}
