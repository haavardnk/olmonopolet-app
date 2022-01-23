import 'package:flutter/material.dart';
import '../helpers/db_helper.dart';

class CartItem {
  final int id;
  final String name;
  final int quantity;
  final double price;
  final bool checked;
  final String? imageUrl;

  CartItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.checked,
    this.imageUrl,
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
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  int get itemCount {
    return _items.length;
  }

  void addItem(int productId, String name, double price, String? imageUrl) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          name: existingCartItem.name,
          quantity: existingCartItem.quantity + 1,
          price: existingCartItem.price,
          checked: existingCartItem.checked,
          imageUrl: existingCartItem.imageUrl,
        ),
      );
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: productId,
          name: name,
          price: price,
          checked: false,
          imageUrl: imageUrl,
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
          id: existingCartItem.id,
          name: existingCartItem.name,
          quantity: existingCartItem.quantity - 1,
          price: existingCartItem.price,
          checked: existingCartItem.checked,
          imageUrl: existingCartItem.imageUrl,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
    updateDb(productId);
  }

  void checkItem(int productId) {
    _items.update(
      productId,
      (existingCartItem) => CartItem(
        id: existingCartItem.id,
        name: existingCartItem.name,
        quantity: existingCartItem.quantity,
        price: existingCartItem.price,
        checked: !existingCartItem.checked,
        imageUrl: existingCartItem.imageUrl,
      ),
    );
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
          'id': _items[productId]!.id,
          'name': _items[productId]!.name,
          'quantity': _items[productId]!.quantity,
          'price': _items[productId]!.price,
          'checked': _items[productId]!.checked ? 1 : 0,
          'imageUrl': _items[productId]!.imageUrl ?? '',
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
            id: item['id'],
            name: item['name'],
            price: item['price'],
            checked: item['checked'] == 0 ? false : true,
            imageUrl: item['imageUrl'],
            quantity: item['quantity'],
          ),
        );
      }
      notifyListeners();
    }
  }
}
