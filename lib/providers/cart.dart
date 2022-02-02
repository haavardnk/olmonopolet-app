import 'package:flutter/material.dart';

import '../helpers/db_helper.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  final int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });
}

class Cart with ChangeNotifier {
  Map<int, CartItem> _items = {};

  Map<int, CartItem> get items {
    return {..._items};
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.product.price * cartItem.quantity;
    });
    return total;
  }

  int get itemCount {
    return _items.length;
  }

  void addItem(int productId, Product product) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          product: existingCartItem.product,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
          product: product,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
    updateDb(productId);
  }

  void removeItem(int productId) {
    _items.remove(productId);
    notifyListeners();
    updateDb(productId);
  }

  void removeSingleItem(int productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          product: existingCartItem.product,
          quantity: existingCartItem.quantity - 1,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
    updateDb(productId);
  }

  void clear() {
    _items = {};
    notifyListeners();
    DBHelper.clear('cart');
  }

  void updateDb(int productId) {
    if (_items.containsKey(productId)) {
      DBHelper.insert(
        'cart',
        {
          'id': _items[productId]!.product.id,
          'name': _items[productId]!.product.name,
          'style': _items[productId]!.product.style,
          'price': _items[productId]!.product.price,
          'volume': _items[productId]!.product.volume,
          'pricePerVolume': _items[productId]!.product.pricePerVolume,
          'stock': _items[productId]!.product.stock,
          'rating': _items[productId]!.product.rating,
          'checkins': _items[productId]!.product.checkins,
          'abv': _items[productId]!.product.abv,
          'imageUrl': _items[productId]!.product.imageUrl,
          'userRating': _items[productId]!.product.userRating,
          'quantity': _items[productId]!.quantity,
        },
      );
    } else {
      DBHelper.removeItem('cart', productId);
    }
  }

  Future<void> fetchAndSetCart() async {
    if (_items.isEmpty) {
      final dataList = await DBHelper.getData('cart');
      for (var item in dataList) {
        _items.putIfAbsent(
          item['id'],
          () => CartItem(
            product: Product(
              id: item['id'],
              name: item['name'],
              style: item['style'],
              price: item['price'],
              volume: item['volume'],
              pricePerVolume: item['pricePerVolume'],
              stock: item['stock'],
              rating: item['rating'],
              checkins: item['checkins'],
              abv: item['abv'],
              imageUrl: item['imageUrl'],
              userRating: item['userRating'],
            ),
            quantity: item['quantity'],
          ),
        );
      }
      notifyListeners();
    }
  }
}
